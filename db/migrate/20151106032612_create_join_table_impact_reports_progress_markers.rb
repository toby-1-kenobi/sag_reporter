class CreateJoinTableImpactReportsProgressMarkers < ActiveRecord::Migration

  def up
    create_join_table :impact_reports, :progress_markers do |t|
      t.index [:impact_report_id, :progress_marker_id], unique: true, name: "index_impact_reports_progress_markers_on_ir_and_pm"
      t.index [:progress_marker_id, :impact_report_id], name: "index_impact_reports_progress_markers_on_pm_and_ir"
    end
    execute <<-SQL
      INSERT INTO impact_reports_progress_markers (impact_report_id, progress_marker_id)
      SELECT id, progress_marker_id FROM impact_reports
      WHERE impact_reports.progress_marker_id IS NOT NULL
    SQL
    remove_column :impact_reports, :progress_marker_id
  end

  def down
    add_reference :impact_reports, :progress_marker, index: true, foreign_key: true
    execute <<-SQL
      UPDATE impact_reports
      SET progress_marker_id = impact_reports_progress_markers_one_pm.progress_marker_id
      FROM (
        SELECT DISTINCT ON (impact_report_id) impact_report_id, impact_reports_progress_markers.progress_marker_id
        FROM impact_reports_progress_markers
      ) AS impact_reports_progress_markers_one_pm
      WHERE impact_reports.id = impact_reports_progress_markers_one_pm.impact_report_id
    SQL
    drop_table :impact_reports_progress_markers
  end

end
