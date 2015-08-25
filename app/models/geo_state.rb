class GeoState < ActiveRecord::Base

  belongs_to :zone
  has_many :users
  has_and_belongs_to_many :languages
  
end
