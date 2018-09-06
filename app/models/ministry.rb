class Ministry < ActiveRecord::Base

  has_many :deliverables, dependent: :destroy
  has_many :facilitator_streams, dependent: :destroy
  has_many :facilitators, through: :facilitator_streams
  has_many :church_ministries, dependent: :destroy
  has_many :church_teams, through: :church_ministries
  has_many :project_streams, dependent: :destroy
  has_many :projects, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  belongs_to :topic

  validates :number, presence: true, uniqueness: true

end
