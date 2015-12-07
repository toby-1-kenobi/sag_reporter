class ReportContentNotNull < ActiveRecord::Migration
  def change
    change_column_null :reports, :content, false
    change_column_null :impact_reports, :content, false
  end
end
