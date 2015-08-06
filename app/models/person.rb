class Person < ActiveRecord::Base

  include ContactDetails

  belongs_to :language

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, length: { is: 10 }, allow_nil: true, numericality: true

end
