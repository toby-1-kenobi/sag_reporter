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
      'mt_society' => Translatable.find_by_identifier('mt_in_society'),
      'mt_church' => Translatable.find_by_identifier('mt_in_church'),
      'needs_society' => Translatable.find_by_identifier('needs_society'),
      'needs_church' => Translatable.find_by_identifier('needs_church')
    }
  end

end
