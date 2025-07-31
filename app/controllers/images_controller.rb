class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_imageable, only: [ :create ]
  before_action :set_image, only: [ :show, :destroy ]

  # POST /images
  # AJAX endpoint for uploading images
  def create
    @image_file = params[:image]

    if @image_file.blank?
      render json: { success: false, error: "No image file provided" }, status: :unprocessable_entity
      return
    end

    begin
      # Create a temporary blob to validate
      blob = ActiveStorage::Blob.create_after_unfurling!(
        io: @image_file.tempfile,
        filename: @image_file.original_filename,
        content_type: @image_file.content_type
      )

      # Associate with tenant for security
      TenantImageService.attach_to_tenant(blob, current_tenant)

      # Attach to the imageable object if provided
      if @imageable
        @imageable.images.attach(blob)

        # Validate the imageable object (this will run our custom validations)
        unless @imageable.valid?
          blob.purge
          render json: {
            success: false,
            errors: @imageable.errors.full_messages
          }, status: :unprocessable_entity
          return
        end
      end

      # Generate thumbnail variant in background
      ImageProcessingJob.perform_later(blob.id, current_tenant.id, [ :thumbnail ])

      # Return success response with image data
      render json: {
        success: true,
        image: {
          id: blob.id,
          filename: blob.filename.to_s,
          content_type: blob.content_type,
          byte_size: blob.byte_size,
          human_size: ImageVariantService.human_file_size(create_attachment_mock(blob)),
          url: rails_blob_url(blob, only_path: true),
          thumbnail_url: ImageVariantService.variant_url(create_attachment_mock(blob), :thumbnail),
          dimensions: ImageVariantService.dimensions(create_attachment_mock(blob))
        }
      }

    rescue => e
      Rails.logger.error "Image upload failed: #{e.message}"
      render json: {
        success: false,
        error: "Failed to upload image. Please try again."
      }, status: :unprocessable_entity
    end
  end

  # GET /images/:id
  # Serve image with tenant verification
  def show
    if TenantImageService.tenant_accessible?(@image.blob, current_tenant)
      # Get variant if requested
      if params[:variant].present? && ImageVariantService::VARIANTS.key?(params[:variant].to_sym)
        variant = ImageVariantService.variant_for(create_attachment_mock(@image.blob), params[:variant].to_sym)
        redirect_to rails_blob_url(variant, only_path: true)
      else
        redirect_to rails_blob_url(@image.blob, only_path: true)
      end
    else
      head :not_found
    end
  end

  # DELETE /images/:id
  # Delete image with proper authorization
  def destroy
    unless TenantImageService.tenant_accessible?(@image.blob, current_tenant)
      render json: { success: false, error: "Image not found" }, status: :not_found
      return
    end

    # Check if user owns the parent object
    attachment = ActiveStorage::Attachment.find_by(blob: @image.blob)
    if attachment && attachment.record.respond_to?(:user) && attachment.record.user != current_user
      render json: { success: false, error: "Not authorized" }, status: :forbidden
      return
    end

    begin
      @image.blob.purge
      render json: { success: true, message: "Image deleted successfully" }
    rescue => e
      Rails.logger.error "Image deletion failed: #{e.message}"
      render json: {
        success: false,
        error: "Failed to delete image. Please try again."
      }, status: :unprocessable_entity
    end
  end

  # POST /images/batch_upload
  # Handle multiple image uploads
  def batch_upload
    @image_files = params[:images] || []

    if @image_files.empty?
      render json: { success: false, error: "No image files provided" }, status: :unprocessable_entity
      return
    end

    uploaded_images = []
    errors = []

    @image_files.each_with_index do |image_file, index|
      begin
        blob = ActiveStorage::Blob.create_after_unfurling!(
          io: image_file.tempfile,
          filename: image_file.original_filename,
          content_type: image_file.content_type
        )

        TenantImageService.attach_to_tenant(blob, current_tenant)

        uploaded_images << {
          id: blob.id,
          filename: blob.filename.to_s,
          content_type: blob.content_type,
          byte_size: blob.byte_size,
          human_size: ImageVariantService.human_file_size(create_attachment_mock(blob)),
          url: rails_blob_url(blob, only_path: true),
          thumbnail_url: ImageVariantService.variant_url(create_attachment_mock(blob), :thumbnail)
        }

        # Generate thumbnail in background
        ImageProcessingJob.perform_later(blob.id, current_tenant.id, [ :thumbnail ])

      rescue => e
        errors << "File #{index + 1} (#{image_file.original_filename}): #{e.message}"
      end
    end

    if uploaded_images.any?
      render json: {
        success: true,
        images: uploaded_images,
        errors: errors.any? ? errors : nil
      }
    else
      render json: {
        success: false,
        error: "Failed to upload any images",
        errors: errors
      }, status: :unprocessable_entity
    end
  end

  private

  def set_imageable
    # Support attaching to questions or blogs
    if params[:question_id].present?
      @imageable = current_tenant.questions.find(params[:question_id])
    elsif params[:blog_id].present?
      @imageable = current_tenant.blogs.find(params[:blog_id])
    end
    # @imageable can be nil for standalone uploads
  end

  def set_image
    @image = ActiveStorage::Blob.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Image not found" }, status: :not_found
  end

  def create_attachment_mock(blob)
    # Create a mock attachment for service methods
    attachment = Object.new
    def attachment.attached?; true; end
    def attachment.blob; @blob; end
    attachment.instance_variable_set(:@blob, blob)
    attachment
  end

  def authenticate_user!
    unless current_user
      render json: { success: false, error: "Authentication required" }, status: :unauthorized
    end
  end
end
