class Report < ActiveRecord::Base

	enum state: [ :archived, :active ]

	belongs_to :reporter, class_name: 'User'
	belongs_to :event
	has_and_belongs_to_many :languages
	has_and_belongs_to_many :topics
	validates :content, presence: true, allow_nil: false
	validates :reporter, presence: true, allow_nil: false

  def self.categories
    {
      'mt_society' => "use of mother tongue in society",
      'mt_church' => "use of mother tongue tools in the local churches",
      'needs_society' => "needs of society",
      'needs_church' => "needs of the churches"
    }
  end

end
