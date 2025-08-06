require "test_helper"

class TenantImageServiceTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  # Disable fixtures for this test
  def self.fixtures(*args)
    # Override to disable fixtures
  end
  def setup
    @tenant1 = Tenant.create!(name: "Test Tenant #{SecureRandom.hex(4)}")
    @tenant2 = Tenant.create!(name: "Test Tenant #{SecureRandom.hex(4)}")

    # Create a test image blob
    @blob = ActiveStorage::Blob.create!(
      key: "test-key-#{SecureRandom.hex}",
      filename: "test.jpg",
      content_type: "image/jpeg",
      metadata: { width: 100, height: 100 },
      byte_size: 1024,
      checksum: "test-checksum"
    )
  end

  def teardown
    @blob&.purge
  end

  test "attach_to_tenant associates blob with tenant" do
    result = TenantImageService.attach_to_tenant(@blob, @tenant1)

    assert result
    assert_equal @tenant1.id, @blob.reload.tenant_id
  end

  test "attach_to_tenant returns false for invalid inputs" do
    assert_not TenantImageService.attach_to_tenant(nil, @tenant1)
    assert_not TenantImageService.attach_to_tenant(@blob, nil)
  end

  test "tenant_accessible? returns true for accessible blob" do
    TenantImageService.attach_to_tenant(@blob, @tenant1)

    assert TenantImageService.tenant_accessible?(@blob, @tenant1)
    assert_not TenantImageService.tenant_accessible?(@blob, @tenant2)
  end

  test "tenant_accessible? returns false for invalid inputs" do
    assert_not TenantImageService.tenant_accessible?(nil, @tenant1)
    assert_not TenantImageService.tenant_accessible?(@blob, nil)
  end

  test "tenant_blobs returns blobs for specific tenant" do
    TenantImageService.attach_to_tenant(@blob, @tenant1)

    tenant1_blobs = TenantImageService.tenant_blobs(@tenant1)
    tenant2_blobs = TenantImageService.tenant_blobs(@tenant2)

    assert_includes tenant1_blobs, @blob
    assert_not_includes tenant2_blobs, @blob
  end

  test "tenant_storage_usage calculates correct usage" do
    TenantImageService.attach_to_tenant(@blob, @tenant1)

    usage = TenantImageService.tenant_storage_usage(@tenant1)
    assert_equal @blob.byte_size, usage

    usage2 = TenantImageService.tenant_storage_usage(@tenant2)
    assert_equal 0, usage2
  end

  test "serve_blob returns blob for authorized tenant" do
    TenantImageService.attach_to_tenant(@blob, @tenant1)

    served_blob = TenantImageService.serve_blob(@blob, @tenant1)
    assert_equal @blob, served_blob

    unauthorized_blob = TenantImageService.serve_blob(@blob, @tenant2)
    assert_nil unauthorized_blob
  end
end
