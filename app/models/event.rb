class Event < ActiveRecord::Base
	
  belongs_to :record_creator, class_name: "User", foreign_key: "user_id"
  has_and_belongs_to_many :purposes
  has_and_belongs_to_many :languages
  has_many :attendances, dependent: :destroy
  has_many :people, through: :attendances
  has_many :impact_reports
  has_many :planning_reports, class_name: "Report"
  has_many :action_points

  def self.yes_no_questions
    questions = Hash.new
    Report.categories.each do |key, value|
      questions[key] = "Was anything said about the <strong>#{value}</strong>?".html_safe
    end
    questions['plan'] = "Were any other <strong>hopes, dreams or challenges?</strong> shared?".html_safe
    questions['impact'] = "Were any other <strong>impact stories</strong> shared?".html_safe
    return questions
  end

end
