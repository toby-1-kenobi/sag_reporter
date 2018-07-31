class Ministry < ActiveRecord::Base

  has_many :congregation_ministries, dependent: :destroy
  has_many :ministry_markers, dependent: :destroy

  validates :name, presence: true

end
