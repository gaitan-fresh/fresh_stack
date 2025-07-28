class ResponsesController < ApplicationController
  before_action :set_response, only: [ :edit, :update, :destroy, :vote_up, :vote_down, :accept ]
  before_action :set_parent, only: [ :create ]
  before_action :require_can_respond!, only: [ :create ]
  before_action :require_can_vote!, only: [ :vote_up, :vote_down ]

  def create
    @response = @parent.responses.build(response_params)
    @response.user = current_user
    @response.tenant = current_tenant

    if @response.save
      redirect_back(fallback_location: root_path, notice: "Response posted successfully!")
    else
      redirect_back(fallback_location: root_path, alert: "Error posting response: #{@response.errors.full_messages.join(', ')}")
    end
  end

  def edit
    redirect_to root_path unless @response.user == current_user
  end

  def update
    redirect_to root_path unless @response.user == current_user

    if @response.update(response_params)
      redirect_back(fallback_location: root_path, notice: "Response updated successfully!")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to root_path unless @response.user == current_user || current_user.admin?

    @response.destroy
    redirect_back(fallback_location: root_path, notice: "Response deleted successfully!")
  end

  def vote_up
    vote(1)
  end

  def vote_down
    vote(-1)
  end

  def accept
    redirect_to root_path unless @response.parent.is_a?(Question) && @response.parent.user == current_user

    @response.accept!
    redirect_back(fallback_location: root_path, notice: "Response accepted!")
  end

  private

  def set_response
    @response = current_tenant.responses.find(params[:id])
  end

  def set_parent
    if params[:question_id]
      @parent = current_tenant.questions.find(params[:question_id])
    elsif params[:response_id]
      @parent = current_tenant.responses.find(params[:response_id])
    end
  end

  def response_params
    params.require(:response).permit(:body)
  end

  def vote(value)
    existing_vote = @response.votes.find_by(user: current_user)

    if existing_vote
      if existing_vote.value == value
        existing_vote.destroy
      else
        existing_vote.update(value: value)
      end
    else
      @response.votes.create(user: current_user, value: value, tenant: current_tenant)
    end

    redirect_back(fallback_location: root_path)
  end
end
