class Tenant < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :blogs, dependent: :destroy
end
