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

  def vote_score
    votes.sum(:value)
  end

  def accepted_response
    responses.find_by(is_accepted: true)
  end
end
