class ProductCategory < ActiveRecord::Base
  has_and_belongs_to_many :mt_resources
  validates :number, presence: true, uniqueness: true
end
