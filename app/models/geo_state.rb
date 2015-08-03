class GeoState < ActiveRecord::Base

  belongs_to :zone
  has_many :users
  
end
