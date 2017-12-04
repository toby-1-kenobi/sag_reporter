class Dialect < ActiveRecord::Base

  belongs_to :language

  validates :name, presence: true

end
