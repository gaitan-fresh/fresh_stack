require "test_helper"

class ImageVariantServiceTest < ActiveSupport::TestCase
  def setup
    # Create a mock image blob for testing
    @blob = ActiveStorage::Blob.create!(
      key: "test-image-#{SecureRandom.hex}",
      filename: "test.jpg",
      content_type: "image/jpeg",
      metadata: { width: 800, height: 600 },
      byte_size: 1024,
      checksum: "test-checksum"
    )
  end

  def teardown
    @blob&.purge
  end

  test "VARIANTS constant contains expected sizes" do
    expected_variants = [ :thumbnail, :small, :medium, :large ]

    expected_variants.each do |variant|
      assert ImageVariantService::VARIANTS.key?(variant), "Missing variant: #{variant}"
    end
  end

  test "processable? returns true for valid image types" do
    valid_types = %w[image/jpeg image/jpg image/png image/gif image/webp]

    valid_types.each do |content_type|
      @blob.update!(content_type: content_type)
      attachment = create_mock_attachment(@blob)

      assert ImageVariantService.processable?(attachment), "Should be processable: #{content_type}"
    end
  end

  test "processable? returns false for invalid image types" do
    invalid_types = %w[text/plain application/pdf video/mp4]

    invalid_types.each do |content_type|
      @blob.update!(content_type: content_type)
      attachment = create_mock_attachment(@blob)

      assert_not ImageVariantService.processable?(attachment), "Should not be processable: #{content_type}"
    end
  end

  test "dimensions returns correct width and height" do
    attachment = create_mock_attachment(@blob)

    dimensions = ImageVariantService.dimensions(attachment)

    assert_equal 800, dimensions[:width]
    assert_equal 600, dimensions[:height]
  end

  test "aspect_ratio calculates correctly" do
    attachment = create_mock_attachment(@blob)

    ratio = ImageVariantService.aspect_ratio(attachment)

    assert_in_delta 1.33, ratio, 0.01 # 800/600 ≈ 1.33
  end

  test "human_file_size formats correctly" do
    attachment = create_mock_attachment(@blob)

    size = ImageVariantService.human_file_size(attachment)

    assert_equal "1.0 KB", size
  end

  test "variant_for_container returns appropriate variant" do
    attachment = create_mock_attachment(@blob)

    # Mock the variant_for method to avoid actual image processing
    ImageVariantService.stub(:variant_for, "mocked_variant") do
      assert_equal "mocked_variant", ImageVariantService.variant_for_container(attachment, 100)
      assert_equal "mocked_variant", ImageVariantService.variant_for_container(attachment, 250)
      assert_equal "mocked_variant", ImageVariantService.variant_for_container(attachment, 500)
      assert_equal "mocked_variant", ImageVariantService.variant_for_container(attachment, 800)
    end
  end

  private

  def create_mock_attachment(blob)
    # Create a mock attachment object
    attachment = Object.new

    def attachment.attached?
      true
    end

    def attachment.blob
      @blob
    end

    attachment.instance_variable_set(:@blob, blob)
    attachment
  end
end
