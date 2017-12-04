class ChangePlanningReport < ActiveRecord::Migration
  def change
  	remove_index :reports, column: :report_type
  	remove_column :reports, :report_type, :integer
  	add_column :reports, :mt_society, :boolean
  	add_column :reports, :mt_church, :boolean
  	add_column :reports, :needs_society, :boolean
  	add_column :reports, :needs_church, :boolean
  	add_reference :reports, :event, index: true, foreign_key: true
  end
end
