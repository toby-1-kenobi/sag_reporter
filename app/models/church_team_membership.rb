class ChurchTeamMembership < ActiveRecord::Base
  
  has_paper_trail
  
  belongs_to :user
  belongs_to :church_team, touch: true
  validates :user, presence: true
  validates :church_team, presence: true
end
