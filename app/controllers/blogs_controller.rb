class BlogsController < ApplicationController
  before_action :set_blog, only: [ :show, :edit, :update, :destroy ]

  def index
    @blogs = current_tenant.blogs.includes(:user, :tags)
    @blogs = @blogs.search(params[:search]) if params[:search].present?
    @blogs = @blogs.joins(:tags).where(tags: { name: params[:tag] }) if params[:tag].present?
    @blogs = @blogs.order(created_at: :desc)
  end

  def show
  end

  def new
    @blog = current_tenant.blogs.build
  end

  def create
    @blog = current_tenant.blogs.build(blog_params)
    @blog.user = current_user

    if @blog.save
      redirect_to @blog, notice: "Blog post created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to root_path unless @blog.user == current_user
  end

  def update
    redirect_to root_path unless @blog.user == current_user

    if @blog.update(blog_params)
      redirect_to @blog, notice: "Blog post updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to root_path unless @blog.user == current_user || current_user.admin?

    @blog.destroy
    redirect_to blogs_path, notice: "Blog post deleted successfully!"
  end

  def search
    @blogs = current_tenant.blogs.includes(:user, :tags)
    @blogs = @blogs.search(params[:q]) if params[:q].present?
    @blogs = @blogs.order(created_at: :desc)
    render :index
  end

  private

  def set_blog
    @blog = current_tenant.blogs.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :body, tag_ids: [], question_ids: [])
  end
end
