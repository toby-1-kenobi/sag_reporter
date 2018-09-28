class ProjectSupervisor < ActiveRecord::Base

  enum role: {
      management: 0,
      organisational_leadership: 1,
      wider: 2
  }

  belongs_to :project
  belongs_to :user

  validates :project, presence: true
  validates :user, presence: true
  validates :role, presence: true

  delegate :name, to: :user

end
