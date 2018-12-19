class Event < ActiveRecord::Base

  include LocationBased
	
  belongs_to :record_creator, class_name: 'User', foreign_key: 'user_id'
  has_and_belongs_to_many :purposes
  has_and_belongs_to_many :languages
  has_many :attendances, dependent: :destroy
  has_many :people, through: :attendances
  has_many :reports

  accepts_nested_attributes_for :reports,
                                reject_if: :all_blank

  accepts_nested_attributes_for :people,
                                reject_if: :all_blank

  validates :event_date, presence: true
  validates :event_label, presence: true
  validates :participant_amount, :numericality => { :greater_than_or_equal_to => 0 }

  before_validation :location_init

  def self.yes_no_questions(user)
    questions = Hash.new
    Report.categories.each do |key, value|
      questions[key] = Translation.get_string('anything_said', user) + ' ' + value.translation_for(user)
    end
    questions['plan'] = Translation.get_string('hopes_challenges', user)
    questions['impact'] = Translation.get_string('other_impact', user)
    return questions
  end

  private

  def location_init
    if self.district_name.present? and self.sub_district_name.present? and self.geo_state and self.sub_district.blank?
      district = geo_state.districts.find_by_name self.district_name
      if district
        self.sub_district = district.sub_districts.find_by_name self.sub_district_name
      end
    end
  end

end
