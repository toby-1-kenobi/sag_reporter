class OutputCount < ActiveRecord::Base

  include StateBased

  belongs_to :output_tally
  belongs_to :user
  belongs_to :language

  before_validation :date_init

  private

  def date_init
  	self.year ||= Date.today.year if new_record?
  	self.month ||= Date.today.month if new_record?
  end

end
