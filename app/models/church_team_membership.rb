class ChurchTeamMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :church_team
  validates :user, presence: true
  validates :church_team, presence: true
end
