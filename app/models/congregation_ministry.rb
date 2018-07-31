class CongregationMinistry < ActiveRecord::Base
  belongs_to :church_congregation
  belongs_to :ministry
end
