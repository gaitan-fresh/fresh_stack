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
      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return nil unless image.attached? && VARIANTS.key?(size)
        image.variant(VARIANTS[size])
      elsif image.respond_to?(:blob) && image.blob.present?
        return nil unless VARIANTS.key?(size)
        image.variant(VARIANTS[size])
      else
        nil
      end
    end

    # Generate all variants for an image (useful for preloading)
    def generate_all_variants(image)
      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return {} unless image.attached?
      elsif image.respond_to?(:blob)
        return {} unless image.blob.present?
      else
        return {}
      end

      variants = {}
      VARIANTS.each do |size, options|
        variants[size] = image.variant(options)
      end
      variants
    end

    # Get variant URL with fallback
    def variant_url(image, size, fallback: nil)
      return fallback unless VARIANTS.key?(size)

      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return fallback unless image.attached?
      elsif image.respond_to?(:blob)
        return fallback unless image.blob.present?
      else
        return fallback
      end

      begin
        variant = image.variant(VARIANTS[size])
        Rails.application.routes.url_helpers.rails_blob_url(variant, only_path: true)
      rescue => e
        Rails.logger.error "Failed to generate variant URL: #{e.message}"
        Rails.logger.error "Backtrace: #{e.backtrace.first(3).join(', ')}"
        fallback
      end
    end

    # Check if an image can be processed (has valid content type)
    def processable?(image)
      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return false unless image.attached?
        blob = image.blob
      elsif image.respond_to?(:blob)
        return false unless image.blob.present?
        blob = image.blob
      else
        return false
      end

      processable_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
      processable_types.include?(blob.content_type)
    end

    # Get image dimensions from metadata
    def dimensions(image)
      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return { width: 0, height: 0 } unless image.attached?
        blob = image.blob
      elsif image.respond_to?(:blob)
        return { width: 0, height: 0 } unless image.blob.present?
        blob = image.blob
      else
        return { width: 0, height: 0 }
      end

      metadata = blob.metadata
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
      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return "" unless image.attached?
      elsif image.respond_to?(:blob)
        return "" unless image.blob.present?
      else
        return ""
      end

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
        # Handle both attachment collections and individual attachments
        if image.respond_to?(:attached?)
          next unless image.attached?
        elsif image.respond_to?(:blob)
          next unless image.blob.present?
        else
          next
        end

        sizes.each do |size|
          # This will generate the variant if it doesn't exist
          variant_for(image, size)
        end
      end
    end

    # Get file size in human readable format
    def human_file_size(image)
      # Handle both attachment collections and individual attachments
      if image.respond_to?(:attached?)
        return "0 B" unless image.attached?
        blob = image.blob
      elsif image.respond_to?(:blob)
        return "0 B" unless image.blob.present?
        blob = image.blob
      else
        return "0 B"
      end

      size = blob.byte_size
      units = [ "B", "KB", "MB", "GB" ]

      return "#{size} B" if size < 1024

      exp = (Math.log(size) / Math.log(1024)).floor
      exp = [ exp, units.length - 1 ].min

      "%.1f %s" % [ size.to_f / (1024 ** exp), units[exp] ]
    end
  end
end
