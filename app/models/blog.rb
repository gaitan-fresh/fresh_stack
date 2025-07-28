class Blog < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_and_belongs_to_many :questions

  validates :title, presence: true
  validates :body, presence: true

  scope :by_tenant, ->(tenant) { where(tenant: tenant) }
  scope :search, ->(query) { where("title LIKE ? OR body LIKE ?", "%#{query}%", "%#{query}%") }
end
