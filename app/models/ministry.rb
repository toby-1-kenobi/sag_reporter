class Ministry < ActiveRecord::Base

  has_many :ministry_markers, dependent: :destroy

  validates :name, presence: true

end
