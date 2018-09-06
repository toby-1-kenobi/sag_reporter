class ProjectStream < ActiveRecord::Base
  belongs_to :project
  belongs_to :ministry
  belongs_to :supervisor, class_name: 'User'
  validates :project, presence: true
  validates :ministry, presence: true
  validates :supervisor, presence: true
end
