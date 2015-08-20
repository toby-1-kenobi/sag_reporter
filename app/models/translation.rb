class Translation < ActiveRecord::Base
  belongs_to :translatable
  belongs_to :language
end
