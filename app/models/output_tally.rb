class OutputTally < ActiveRecord::Base

  belongs_to :topic
  has_many :output_counts, dependent: :destroy
  
end
