class PhoneMessage < ActiveRecord::Base

  has_paper_trail

  belongs_to :user
  validates :user, presence: true
  validates :content, presence: true
  validate :user_has_phone

  scope :pending, ->{ where(sent_at: nil).where(error_messages: nil) }
  scope :expired, ->{ where('expiration < ?', Time.now) }

  def self.update_expired
    self.pending.expired.each do |message|
      message.update_attribute(:error_messages, 'Expired without sending')
    end
  end

  private

  def user_has_phone
    errors.add(:user_id, 'must have phone number') unless user.phone.present?
  end

end
