class Deliverable < ActiveRecord::Base

  enum calculation_method: {
      most_recent: 0,
      sum_of_all: 1
  }

  enum reporter: {
      church_team: 0,
      facilitator: 1,
      supervisor: 2,
      auto: 3
  }

  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :quarterly_targets, dependent: :restrict_with_error
  validates :ministry, presence: true
  validates :number, presence: true, uniqueness: { scope: :ministry }

  def translation_key
    "#{ministry.code.upcase}#{sprintf('%02d', number)}"
  end

  def short_form
    I18n.t("deliverables.short_form.#{translation_key}")
  end

end
