class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def new
    @user = User.new
    @tenants = Tenant.all
    redirect_to root_path if current_user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully!"
    else
      @tenants = Tenant.all
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_path unless @user.tenant == current_tenant
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :tenant_id)
  end
end
