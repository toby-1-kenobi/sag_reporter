class AddSignificantToReports < ActiveRecord::Migration
  def change
    add_column :reports, :significant, :boolean, default: false, null:false
  end
end
