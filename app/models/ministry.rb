class Ministry < ActiveRecord::Base

  has_many :congregation_ministries, dependent: :destroy

  validates :name, presence: true

end
