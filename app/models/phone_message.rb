class PhoneMessage < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :content, presence: true
  validate :user_has_phone

  scope :pending, ->{ where(sent_at: nil).where(error_messages: nil) }

  private

  def user_has_phone
    errors.add(:user_id, 'must have phone number') unless user.phone.present?
  end

end
