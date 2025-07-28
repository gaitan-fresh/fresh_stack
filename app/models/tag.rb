class Tag < ApplicationRecord
  belongs_to :tenant
  has_many :taggings, dependent: :destroy
  has_many :questions, through: :taggings, source: :taggable, source_type: "Question"
  has_many :blogs, through: :taggings, source: :taggable, source_type: "Blog"

  validates :name, presence: true, uniqueness: { scope: :tenant_id }

  scope :by_tenant, ->(tenant) { where(tenant: tenant) }
  scope :popular, -> { joins(:taggings).group(:id).order("COUNT(taggings.id) DESC") }
end
