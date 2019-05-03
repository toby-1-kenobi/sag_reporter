class RegistrationApproval < ActiveRecord::Base

  has_paper_trail

  belongs_to :registering_user, class_name: 'User', inverse_of: :registration_approvals
  belongs_to :approver, class_name: 'User', inverse_of: :approved_registrations
  validates :registering_user, presence: true, uniqueness: { scope: :approver }
  validates :approver, presence: true, uniqueness: { scope: :registering_user }
end
