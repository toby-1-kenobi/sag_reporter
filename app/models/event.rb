class Event < ActiveRecord::Base
	
  belongs_to :record_creator, class_name: "User", foreign_key: "user_id"
  has_and_belongs_to_many :purposes
  has_and_belongs_to_many :languages
  has_many :attendances, dependent: :destroy
  has_many :people, through: :attendances

end
