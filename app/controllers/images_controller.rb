class ImagesController < ApplicationController
  before_action :authenticate_user!

  def show
    # Find the attachment by signed_id for security
    attachment = ActiveStorage::Attachment.find_by(id: params[:id])

    if attachment && can_access_image?(attachment)
      redirect_to url_for(attachment.blob)
    else
      head :not_found
    end
  end

  def destroy
    attachment = ActiveStorage::Attachment.find_by(id: params[:id])

    if attachment && can_delete_image?(attachment)
      attachment.purge
      render json: { success: true, message: "Image deleted successfully" }
    else
      render json: { success: false, error: "Image not found or access denied" }, status: :not_found
    end
  end

  private

  def can_access_image?(attachment)
    return false unless attachment

    # Check if the attachment belongs to a record owned by current user or tenant
    record = attachment.record
    case record
    when Question
      record.tenant == current_tenant
    when Blog
      record.tenant == current_tenant
    else
      false
    end
  end

  def can_delete_image?(attachment)
    return false unless attachment

    # Check if user can delete this image
    record = attachment.record
    case record
    when Question
      record.user == current_user && record.tenant == current_tenant
    when Blog
      record.user == current_user && record.tenant == current_tenant
    else
      false
    end
  end
end
