class TallyUpdate < ActiveRecord::Base

  belongs_to :languages_tally
  has_one :tally, through: :languages_tally
  has_one :language, through: :languages_tally
  belongs_to :user

  validates :amount, numericality: { only_integer: true }

end
