class Dialect < ActiveRecord::Base

  has_paper_trail

  belongs_to :language

  validates :name, presence: true

end
