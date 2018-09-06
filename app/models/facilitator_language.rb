class FacilitatorLanguage < ActiveRecord::Base
  belongs_to :language
  belongs_to :facilitator
  validates :language, presence: true
  validates :facilitator, presence: true, uniqueness: { scope: :language }
end
