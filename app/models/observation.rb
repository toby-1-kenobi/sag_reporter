class Observation < ActiveRecord::Base
  belongs_to :report
  belongs_to :person
  validates :report, presence: true, uniqueness: { scope: :person }
  validates :person, presence: true
end
