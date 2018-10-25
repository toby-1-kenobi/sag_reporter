class ProjectLanguage < ActiveRecord::Base

  belongs_to :project, touch: true
  belongs_to :state_language

  validates :project, presence: true
  validates :state_language, presence: true, uniqueness: { scope: :project }

end
