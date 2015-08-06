class Event < ActiveRecord::Base

	enum purpose: [ :plan, :disciple, :serve, :distribute, :develop_leaders ]
	
  belongs_to :record_creator, class_name: "User", foreign_key: "user_id"

    def self.purpose_text
    	{
    		'plan' => "Churches to pray, discuss and plan what is needed in their situation",
    		'disciple' => "Churches to disciple the believers",
    		'serve' => "Churches to serve society",
    		'distribute' => "Churches to distribute mother tongue tools",
    		'develop_leaders' => "Church leaders to be developed"
    	}
    end

end
