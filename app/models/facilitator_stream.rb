class FacilitatorStream < ActiveRecord::Base
  belongs_to :ministry
  belongs_to :facilitator

  validates :ministry, presence: true
  validates :facilitator, presence: true, uniqueness: { scope: :ministry }
end
