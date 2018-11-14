class ChurchTeam < ActiveRecord::Base

  belongs_to :organisation
  belongs_to :state_language
  has_many :church_ministries, dependent: :destroy
  has_many :ministries, through: :church_ministries
  has_many :facilitator_feedbacks, through: :church_ministries
  has_many :church_team_memberships, dependent: :destroy
  has_many :users, through: :church_team_memberships

  validates :leader, presence: true
  validates :state_language, presence: true

  scope :in_project, ->(project) { joins(:ministries).where('ministries.id in (?)', project.ministries.pluck(:id)).where(state_language: project.state_languages).uniq }

  def full_name
    church_name = "#{organisation.name} with #{leader}"
    if name.present?
      "#{church_name} - #{name}"
    else
      church_name
    end
  end
end
