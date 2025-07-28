class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_tenant
  before_action :authenticate_user!

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def current_tenant
    @current_tenant ||= current_user&.tenant || Tenant.first
  end
  helper_method :current_tenant

  def authenticate_user!
    redirect_to new_session_path unless current_user
  end

  def set_current_tenant
    ApplicationRecord.current_tenant = current_tenant if current_tenant
  end

  def require_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def require_can_respond!
    redirect_to root_path, alert: "Access denied." unless current_user&.can_respond?
  end

  def require_can_vote!
    redirect_to root_path, alert: "Access denied." unless current_user&.can_vote?
  end
end
