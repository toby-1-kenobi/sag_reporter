class ChangePlanningReport < ActiveRecord::Migration
  def change
  	remove_index :reports, name: "index_reports_on_report_type"
  	remove_column :reports, :report_type
  	add_column :reports, :mt_social, :boolean
  	add_column :reports, :mt_church, :boolean
  	add_column :reports, :needs_social, :boolean
  	add_column :reports, :needs_church, :boolean
  	add_reference :reports, :event, index: true, foreign_key: true
  end
end
