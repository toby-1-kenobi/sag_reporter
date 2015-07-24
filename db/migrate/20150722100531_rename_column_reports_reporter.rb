class RenameColumnReportsReporter < ActiveRecord::Migration
  def change
  	rename_column :reports, :reporter, :reporter_id
  end
end
