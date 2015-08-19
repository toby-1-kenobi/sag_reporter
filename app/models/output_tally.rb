class OutputTally < ActiveRecord::Base

  belongs_to :topic
  has_many :output_counts, dependent: :destroy

  def total(languages, year, month)
  	total = 0
  	languages.each do |language|
  	  counts = OutputCount.where(
  	  	output_tally: self,
  	  	language: language, 
  	  	year: year,
  	  	month: month
  	  )
  	  total += (counts.inject(0){ |sum, count| sum + count.amount } || 0)
  	end
  	return total
  end
  
end
