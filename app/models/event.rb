class Event < ActiveRecord::Base

  include StateBased
	
  belongs_to :record_creator, class_name: "User", foreign_key: "user_id"
  has_and_belongs_to_many :purposes
  has_and_belongs_to_many :languages
  has_many :attendances, dependent: :destroy
  has_many :people, through: :attendances
  has_many :impact_reports
  has_many :planning_reports, class_name: "Report"
  has_many :action_points

  def self.yes_no_questions(user)
    questions = Hash.new
    Report.categories.each do |key, value|
      questions[key] = "#{Translation.get_string('anything_said', user)} <strong>#{value.translation_for(user)}</strong>?".html_safe
    end
    questions['plan'] = Translation.get_string('hopes_challenges', user)
    questions['impact'] = Translation.get_string('other_impact', user)
    return questions
  end

end
