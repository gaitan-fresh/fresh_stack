class QuestionsController < ApplicationController
  before_action :set_question, only: [ :show, :edit, :update, :destroy, :vote_up, :vote_down, :summarize ]
  before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :require_can_vote!, only: [ :vote_up, :vote_down ]

  def index
    @questions = current_tenant.questions.includes(:user, :tags, :votes)
    @questions = @questions.search(params[:search]) if params[:search].present?
    @questions = @questions.joins(:tags).where(tags: { name: params[:tag] }) if params[:tag].present?
    @questions = @questions.order(created_at: :desc)
  end

  def show
    @response = Response.new
    @responses = @question.responses.includes(:user, :votes, responses: [ :user, :votes ])
  end

  def new
    @question = current_tenant.questions.build
  end

  def create
    @question = current_tenant.questions.build(question_params.except(:new_tags))
    @question.user = current_user

    if @question.save
      # Process tags after saving the question
      @question.process_tags(question_params[:tag_ids], question_params[:new_tags])
      redirect_to @question, notice: "Question created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question.update(question_params.except(:new_tags))
      # Process tags after updating the question
      @question.process_tags(question_params[:tag_ids], question_params[:new_tags])
      redirect_to @question, notice: "Question updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: "Question deleted successfully!"
  end

  def vote_up
    vote(1)
  end

  def vote_down
    vote(-1)
  end

  def search
    @questions = current_tenant.questions.includes(:user, :tags, :votes)
    @questions = @questions.search(params[:q]) if params[:q].present?
    @questions = @questions.order(created_at: :desc)
    render :index
  end

  def summarize
    ai_service = AiSummarizerService.new
    summary = ai_service.summarize_question(@question)

    render json: {
      success: true,
      summary: summary,
      question_title: @question.title
    }
  rescue => e
    Rails.logger.error "Question summarization failed: #{e.message}"
    render json: {
      success: false,
      error: "Failed to generate summary. Please try again."
    }, status: :unprocessable_entity
  end

  private

  def set_question
    @question = current_tenant.questions.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, :new_tags, tag_ids: [])
  end

  def vote(value)
    existing_vote = @question.votes.find_by(user: current_user)

    if existing_vote
      if existing_vote.value == value
        existing_vote.destroy
      else
        existing_vote.update(value: value)
      end
    else
      @question.votes.create(user: current_user, value: value, tenant: current_tenant)
    end

    redirect_back(fallback_location: @question)
  end
end
