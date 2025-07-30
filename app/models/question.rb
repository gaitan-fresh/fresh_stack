class Question < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  has_many :responses, as: :parent, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_and_belongs_to_many :blogs

  validates :title, presence: true
  validates :body, presence: true

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
end
