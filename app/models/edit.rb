class Edit < ActiveRecord::Base

  enum status: {
      auto_approve: 0,
      pending_single_approval: 1,
      pending_double_approval: 2,
      pending_national_approval: 3,
      approved: 4,
      rejected: 5
  }

  belongs_to :user
  belongs_to :curated_by, class_name: 'User'

  validates :user, presence: true
  validates :table_name, presence: true
  validates :field_name, presence: true
  validates :old_value, presence: true
  validates :new_value, presence: true
  validates :status, inclusion: { in: statuses.keys }

end
