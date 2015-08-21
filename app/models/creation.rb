class Creation < ActiveRecord::Base
  belongs_to :person
  belongs_to :mt_resource
end
