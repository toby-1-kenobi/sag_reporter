class VillageWorker < ActiveRecord::Base
  belongs_to :worker, class_name: 'User'
  belongs_to :village

  validates :worker, presence: true
  validates :village, presence: true
end
