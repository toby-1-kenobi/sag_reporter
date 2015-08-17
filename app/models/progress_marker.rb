class ProgressMarker < ActiveRecord::Base

  belongs_to :topic
  has_many :language_progresses, dependent: :destroy
  has_many :languages, through: :language_progresses 

  def self.weight_text
  	{
  		1 => "Expect to see",
  		2 => "Like to see",
  		3 => "Love to see"
  	}
  end

end
