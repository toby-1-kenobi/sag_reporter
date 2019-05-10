class Creation < ActiveRecord::Base

  has_paper_trail

  belongs_to :person
  belongs_to :mt_resource

  validates :person, presence: true
  validates :mt_resource, presence: true
  #TODO: add null constraints to db table

end
