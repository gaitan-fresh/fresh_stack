class ImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(blob_id, tenant_id, variants = [ :thumbnail ])
    blob = ActiveStorage::Blob.find_by(id: blob_id)
    tenant = Tenant.find_by(id: tenant_id)

    return unless blob && tenant

    # Ensure blob belongs to tenant
    unless TenantImageService.tenant_accessible?(blob, tenant)
      Rails.logger.warn "Attempted to process blob #{blob_id} for unauthorized tenant #{tenant_id}"
      return
    end

    # Generate requested variants
    variants.each do |variant_name|
      begin
        case variant_name
        when :thumbnail
          blob.variant(resize_to_limit: [ 150, 150 ]).processed
        when :small
          blob.variant(resize_to_limit: [ 300, 200 ]).processed
        when :medium
          blob.variant(resize_to_limit: [ 600, 400 ]).processed
        when :large
          blob.variant(resize_to_limit: [ 1200, 800 ]).processed
        end

        Rails.logger.info "Generated #{variant_name} variant for blob #{blob_id}"
      rescue => e
        Rails.logger.error "Failed to generate #{variant_name} variant for blob #{blob_id}: #{e.message}"
      end
    end
  end
end
