class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :question, optional: true
  belongs_to :response, optional: true
  belongs_to :tenant

  validates :value, presence: true, inclusion: { in: [ -1, 1 ] }
  validates :user_id, uniqueness: { scope: [ :question_id, :response_id ] }
  validate :must_have_question_or_response

  scope :upvotes, -> { where(value: 1) }
  scope :downvotes, -> { where(value: -1) }

  private

  def must_have_question_or_response
    if question_id.blank? && response_id.blank?
      errors.add(:base, "Vote must be associated with either a question or response")
    elsif question_id.present? && response_id.present?
      errors.add(:base, "Vote cannot be associated with both question and response")
    end
  end
end
