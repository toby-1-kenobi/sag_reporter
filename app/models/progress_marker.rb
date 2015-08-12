class ProgressMarker < ActiveRecord::Base

  belongs_to :topic

  def self.weight_text
  	{
  		1 => "Expect to see",
  		2 => "Like to see",
  		3 => "Love to see"
  	}
  end

end
