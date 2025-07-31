class Question < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  has_many :responses, as: :parent, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_and_belongs_to_many :blogs

  # Image attachments
  has_many_attached :images

  validates :title, presence: true
  validates :body, presence: true

  # Image validations
  validate :images_count_limit
  validate :images_size_limit
  validate :images_content_type

  scope :by_tenant, ->(tenant) { where(tenant: tenant) }
  scope :search, ->(query) { where("title LIKE ? OR body LIKE ?", "%#{query}%", "%#{query}%") }

  # Virtual attribute for handling new tags
  attr_accessor :new_tags

  def upvotes_count
    votes.upvotes.count
  end

  def downvotes_count
    votes.downvotes.count
  end

  def net_vote_score
    votes.sum(:value)
  end

  def total_votes
    upvotes_count + downvotes_count
  end

  def accepted_response
    responses.find_by(is_accepted: true)
  end

  # Image helper methods
  def thumbnail_images
    images.map { |img| ImageVariantService.variant_for(img, :thumbnail) }.compact
  end

  def has_images?
    images.attached? && images.any?
  end

  def image_count
    images.attached? ? images.count : 0
  end

  # Handle new tags creation
  def process_tags(tag_ids, new_tags_string)
    # Clear existing tags
    self.tags.clear

    # Add existing tags
    if tag_ids.present?
      existing_tags = tenant.tags.where(id: tag_ids)
      self.tags << existing_tags
    end

    # Create and add new tags
    if new_tags_string.present?
      new_tag_names = new_tags_string.split(",").map(&:strip).reject(&:blank?)
      new_tag_names.each do |tag_name|
        # Find or create tag for this tenant
        tag = tenant.tags.find_or_create_by(name: tag_name.downcase)
        self.tags << tag unless self.tags.include?(tag)
      end
    end
  end

  private

  # Image validation methods
  def images_count_limit
    return unless images.attached?

    if images.count > 10
      errors.add(:images, "cannot exceed 10 images per question")
    end
  end

  def images_size_limit
    return unless images.attached?

    images.each do |image|
      if image.blob.byte_size > 5.megabytes
        errors.add(:images, "each image must be less than 5MB")
      end
    end
  end

  def images_content_type
    return unless images.attached?

    allowed_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
    images.each do |image|
      unless allowed_types.include?(image.blob.content_type)
        errors.add(:images, "must be JPEG, PNG, GIF, or WebP format")
      end
    end
  end
end
