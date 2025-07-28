class Response < ApplicationRecord
  belongs_to :user
  belongs_to :parent, polymorphic: true
  belongs_to :tenant
  has_many :responses, as: :parent, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :body, presence: true

  scope :by_tenant, ->(tenant) { where(tenant: tenant) }
  scope :accepted, -> { where(is_accepted: true) }

  def vote_score
    votes.sum(:value)
  end

  def accept!
    # Only one response per question can be accepted
    if parent.is_a?(Question)
      parent.responses.where(is_accepted: true).update_all(is_accepted: false)
      update!(is_accepted: true)
    end
  end

  def nested_responses
    responses.includes(:user, :votes)
  end
end
