class MinistryWorker < ActiveRecord::Base
  belongs_to :ministry
  belongs_to :worker, class_name: 'User'

  validates :ministry, presence: true
  validates :worker, presence: true, uniqueness: { scope: :ministry }
end
