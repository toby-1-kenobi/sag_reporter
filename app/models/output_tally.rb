class OutputTally < ActiveRecord::Base

  belongs_to :topic
  has_many :output_counts, dependent: :destroy

  def total(geo_state, languages, year, month)
  	total = 0
  	languages.each do |language|
  	  counts = OutputCount.where(
  	  	output_tally: self,
  	  	language: language,
        geo_state: geo_state, 
  	  	year: year,
  	  	month: month
  	  )
  	  total += (counts.inject(0){ |sum, count| sum + count.amount } || 0)
  	end
  	return total
  end
  
end
