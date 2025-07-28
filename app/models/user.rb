class User < ApplicationRecord
  has_secure_password

  belongs_to :tenant
  has_many :questions, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :blogs, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin viewer readonly] }

  def can_post_questions?
    role == "admin"
  end

  def can_respond?
    role == "admin" || role == "viewer"
  end

  def can_vote?
    role == "admin" || role == "viewer"
  end

  def admin?
    role == "admin"
  end

  def viewer?
    role == "viewer"
  end

  def read_only?
    role == "readonly"
  end
end
