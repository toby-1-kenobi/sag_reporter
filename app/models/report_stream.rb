class ReportStream < ActiveRecord::Base
  belongs_to :report
  belongs_to :ministry
  validates :report, presence: true
  validates :ministry, presence: true, uniqueness: { scope: :report }
end
