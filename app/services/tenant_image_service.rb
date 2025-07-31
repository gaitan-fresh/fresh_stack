class TenantImageService
  class << self
    # Associate a blob with a tenant
    def attach_to_tenant(blob, tenant)
      return false unless blob && tenant

      blob.update!(tenant_id: tenant.id)
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to attach blob to tenant: #{e.message}"
      false
    end

    # Check if a blob is accessible by a tenant
    def tenant_accessible?(blob, tenant)
      return false unless blob && tenant

      blob.tenant_id == tenant.id
    end

    # Get all blobs for a tenant
    def tenant_blobs(tenant)
      return ActiveStorage::Blob.none unless tenant

      ActiveStorage::Blob.where(tenant_id: tenant.id)
    end

    # Clean up orphaned blobs for a tenant (blobs not attached to any record)
    def cleanup_orphaned_blobs(tenant)
      return 0 unless tenant

      orphaned_blobs = tenant_blobs(tenant).left_joins(:attachments)
                                          .where(active_storage_attachments: { id: nil })

      count = orphaned_blobs.count
      orphaned_blobs.find_each(&:purge)
      count
    end

    # Get storage usage for a tenant in bytes
    def tenant_storage_usage(tenant)
      return 0 unless tenant

      tenant_blobs(tenant).sum(:byte_size)
    end

    # Verify tenant access and serve blob
    def serve_blob(blob, tenant)
      return nil unless tenant_accessible?(blob, tenant)

      blob
    end

    # Batch attach multiple blobs to a tenant
    def batch_attach_to_tenant(blobs, tenant)
      return false unless tenant && blobs.present?

      ActiveStorage::Blob.transaction do
        blobs.each do |blob|
          attach_to_tenant(blob, tenant)
        end
      end
      true
    rescue => e
      Rails.logger.error "Failed to batch attach blobs to tenant: #{e.message}"
      false
    end
  end
end
