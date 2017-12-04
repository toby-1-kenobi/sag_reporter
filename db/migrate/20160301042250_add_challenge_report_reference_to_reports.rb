class AddChallengeReportReferenceToReports < ActiveRecord::Migration
  def change
    add_reference :reports, :challenge_report, index: true, foreign_key: true
  end
end
