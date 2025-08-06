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
    Rails.logger.info "Question params: #{question_params.inspect}"
    Rails.logger.info "Images present: #{question_params[:images].present?}"
    Rails.logger.info "Images count: #{question_params[:images]&.count || 0}"

    @question = current_tenant.questions.build(question_params.except(:new_tags, :images))
    @question.user = current_user

    if @question.save
      Rails.logger.info "Question saved with ID: #{@question.id}"

      # Process tags after saving the question
      @question.process_tags(question_params[:tag_ids], question_params[:new_tags])

      # Handle image attachments
      if question_params[:images].present?
        Rails.logger.info "Processing #{question_params[:images].count} images"
        attach_images_to_question
        Rails.logger.info "Images attached. Total images: #{@question.images.count}"
      end

      redirect_to @question, notice: "Question created successfully!"
    else
      Rails.logger.error "Question validation failed: #{@question.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question.update(question_params.except(:new_tags, :images))
      # Process tags after updating the question
      @question.process_tags(question_params[:tag_ids], question_params[:new_tags])

      # Handle image attachments
      attach_images_to_question if question_params[:images].present?

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
    params.require(:question).permit(:title, :body, :new_tags, tag_ids: [], images: [])
  end

  def attach_images_to_question
    return unless question_params[:images].present?

    question_params[:images].each do |image|
      next if image.blank?

      begin
        # Attach the image to the question
        @question.images.attach(image)
        Rails.logger.info "Attached image: #{image.original_filename} to question #{@question.id}"
      rescue => e
        Rails.logger.error "Failed to attach image: #{e.message}"
        next
      end
    end

    # Associate newly attached blobs with tenant
    if @question.images.attached?
      @question.images.blobs.each do |blob|
        begin
          TenantImageService.attach_to_tenant(blob, current_tenant)
        rescue => e
          Rails.logger.error "Failed to associate blob with tenant: #{e.message}"
        end
      end
    end

    # Generate thumbnails in background (optional - can be disabled for debugging)
    if @question.images.attached?
      @question.images.blobs.each do |blob|
        begin
          ImageProcessingJob.perform_later(blob.id, current_tenant.id, [ :thumbnail, :small ])
        rescue => e
          Rails.logger.error "Failed to queue image processing job: #{e.message}"
        end
      end
    end
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
