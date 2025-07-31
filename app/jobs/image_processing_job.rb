class ImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(image_id, tenant_id, variants = [ :thumbnail, :small ])
    # Find the image blob
    blob = ActiveStorage::Blob.find_by(id: image_id)
    return unless blob

    # Verify tenant access
    return unless blob.tenant_id == tenant_id

    # Find the attachment
    attachment = ActiveStorage::Attachment.find_by(blob_id: blob.id)
    return unless attachment

    begin
      # Generate specified variants
      variants.each do |variant_name|
        next unless ImageVariantService::VARIANTS.key?(variant_name)

        variant_options = ImageVariantService::VARIANTS[variant_name]

        # This will generate and store the variant
        attachment.variant(variant_options).processed

        Rails.logger.info "Generated #{variant_name} variant for image #{image_id}"
      end
    rescue => e
      Rails.logger.error "Failed to process image variants for #{image_id}: #{e.message}"
      raise e
    end
  end
end
