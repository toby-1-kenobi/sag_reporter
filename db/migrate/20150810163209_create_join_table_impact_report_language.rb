class CreateJoinTableImpactReportLanguage < ActiveRecord::Migration
  def change
    create_join_table :impact_reports, :languages do |t|
      # t.index [:impact_report_id, :language_id]
      # t.index [:language_id, :impact_report_id]
    end
    add_index :impact_reports_languages, [:impact_report_id, :language_id], unique: true, name: 'index_impact_reports_languages'
  end
end
