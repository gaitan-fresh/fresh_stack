class TenantImageService
  def self.attach_to_tenant(blob, tenant)
    # Add tenant_id to the blob for multi-tenant isolation
    blob.update!(tenant_id: tenant.id) if blob.respond_to?(:tenant_id=)
  rescue => e
    Rails.logger.error "Failed to attach blob to tenant: #{e.message}"
  end

  def self.tenant_accessible?(blob, tenant)
    # Check if the blob belongs to the tenant
    blob.tenant_id == tenant.id if blob.respond_to?(:tenant_id)
  end

  def self.cleanup_orphaned_blobs(tenant)
    # Find blobs that belong to this tenant but aren't attached to anything
    tenant_blobs = ActiveStorage::Blob.where(tenant_id: tenant.id)

    tenant_blobs.each do |blob|
      if blob.attachments.empty?
        blob.purge
      end
    end
  end
end
