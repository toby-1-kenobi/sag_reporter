class Village < ActiveRecord::Base
  belongs_to :geo_state

  validate :name, presence: true
end
