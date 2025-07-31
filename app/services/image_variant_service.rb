class ImageVariantService
  # Define standard image variants for consistent sizing across the app
  VARIANTS = {
    thumbnail: { resize_to_limit: [ 150, 150 ] },
    small: { resize_to_limit: [ 300, 200 ] },
    medium: { resize_to_limit: [ 600, 400 ] },
    large: { resize_to_limit: [ 1200, 800 ] }
  }.freeze

  class << self
    # Generate a specific variant for an image
    def variant_for(image, size)
      return nil unless image.attached? && VARIANTS.key?(size)

      image.variant(VARIANTS[size])
    end

    # Generate all variants for an image (useful for preloading)
    def generate_all_variants(image)
      return {} unless image.attached?

      variants = {}
      VARIANTS.each do |size, options|
        variants[size] = image.variant(options)
      end
      variants
    end

    # Get variant URL with fallback
    def variant_url(image, size, fallback: nil)
      return fallback unless image.attached? && VARIANTS.key?(size)

      begin
        Rails.application.routes.url_helpers.rails_blob_url(
          image.variant(VARIANTS[size]),
          only_path: true
        )
      rescue => e
        Rails.logger.error "Failed to generate variant URL: #{e.message}"
        fallback
      end
    end

    # Check if an image can be processed (has valid content type)
    def processable?(image)
      return false unless image.attached?

      processable_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
      processable_types.include?(image.blob.content_type)
    end

    # Get image dimensions from metadata
    def dimensions(image)
      return { width: 0, height: 0 } unless image.attached?

      metadata = image.blob.metadata
      {
        width: metadata["width"] || 0,
        height: metadata["height"] || 0
      }
    end

    # Calculate aspect ratio
    def aspect_ratio(image)
      dims = dimensions(image)
      return 1.0 if dims[:height] == 0

      dims[:width].to_f / dims[:height].to_f
    end

    # Generate responsive image srcset
    def responsive_srcset(image, sizes = [ :small, :medium, :large ])
      return "" unless image.attached?

      srcset_parts = []
      sizes.each do |size|
        next unless VARIANTS.key?(size)

        variant_url = variant_url(image, size)
        width = VARIANTS[size][:resize_to_limit][0]
        srcset_parts << "#{variant_url} #{width}w" if variant_url
      end

      srcset_parts.join(", ")
    end

    # Get appropriate variant based on container size
    def variant_for_container(image, container_width)
      return variant_for(image, :thumbnail) if container_width <= 150
      return variant_for(image, :small) if container_width <= 300
      return variant_for(image, :medium) if container_width <= 600

      variant_for(image, :large)
    end

    # Preload variants in background (for performance)
    def preload_variants(images, sizes = [ :thumbnail, :small ])
      return unless images.respond_to?(:each)

      images.each do |image|
        next unless image.attached?

        sizes.each do |size|
          # This will generate the variant if it doesn't exist
          variant_for(image, size)
        end
      end
    end

    # Get file size in human readable format
    def human_file_size(image)
      return "0 B" unless image.attached?

      size = image.blob.byte_size
      units = [ "B", "KB", "MB", "GB" ]

      return "#{size} B" if size < 1024

      exp = (Math.log(size) / Math.log(1024)).floor
      exp = [ exp, units.length - 1 ].min

      "%.1f %s" % [ size.to_f / (1024 ** exp), units[exp] ]
    end
  end
end
