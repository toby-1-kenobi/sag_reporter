class Organisation < ActiveRecord::Base
  belongs_to :parent, class_name: 'Organisation', inverse_of: :children
  has_many :children, class_name: 'Organisation', inverse_of: :parent
  validates :name, presence: true, allow_blank: false, allow_nil: false, uniqueness: true
  validates :abbreviation, uniqueness: true, allow_nil: true
end
