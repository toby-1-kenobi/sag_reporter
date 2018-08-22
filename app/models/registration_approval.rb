class RegistrationApproval < ActiveRecord::Base
  belongs_to :registering_user, class_name: 'User'
  belongs_to :approver, class_name: 'User'
  validates :registering_user, presence: true, uniqueness: { scope: :approver }
  validates :approver, presence: true, uniqueness: { scope: :registering_user }
end
