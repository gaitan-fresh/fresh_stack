class TagsController < ApplicationController
  def index
    @tags = current_tenant.tags.includes(:taggings)

    # Add search functionality
    if params[:search].present?
      @tags = @tags.where("tags.name LIKE ?", "%#{params[:search]}%")
    end

    # Sort by usage count (most used first)
    @tags = @tags.sort_by { |tag| -tag.taggings.size }
  end

  def show
    @tag = current_tenant.tags.find_by!(name: params[:id])

    # Get questions with this tag
    @questions = current_tenant.questions
                              .joins(:tags)
                              .where(tags: { id: @tag.id })
                              .includes(:user, :tags, :votes, :responses)
                              .order(created_at: :desc)

    # Get blogs with this tag
    @blogs = current_tenant.blogs
                          .joins(:tags)
                          .where(tags: { id: @tag.id })
                          .includes(:user, :tags)
                          .order(created_at: :desc)

    # Pagination could be added here if needed
    @questions = @questions.limit(20)
    @blogs = @blogs.limit(10)
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
