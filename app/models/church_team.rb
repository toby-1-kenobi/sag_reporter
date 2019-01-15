class ChurchTeam < ActiveRecord::Base

  belongs_to :organisation
  belongs_to :state_language
  has_many :church_ministries, dependent: :destroy
  has_many :ministries, through: :church_ministries
  has_many :ministry_outputs, through: :church_ministries
  has_many :facilitator_feedbacks, through: :church_ministries
  has_many :church_team_memberships, dependent: :destroy
  has_many :users, through: :church_team_memberships
  has_many :reports, dependent: :nullify

  validates :leader, presence: true
  validates :state_language, presence: true

  scope :in_project, ->(project) { joins(:ministries).where(church_ministries: {status: 0}).where('ministries.id in (?)', project.ministries.pluck(:id)).where(state_language: project.state_languages).uniq }

  def full_name
    if organisation.present?
      org_name = organisation.name
    else
      org_name = 'Independant'
    end
    church_name = "#{org_name} with #{leader}"
    if name.present?
      "#{church_name} - #{name}"
    else
      church_name
    end
  end
end
