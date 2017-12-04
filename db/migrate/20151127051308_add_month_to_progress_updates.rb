class AddMonthToProgressUpdates < ActiveRecord::Migration
  def up
    add_column :progress_updates, :month, :integer
    add_column :progress_updates, :year, :integer
    ProgressUpdate.all.each do |pu|
      pu.month = pu.created_at.month
      pu.year = pu.created_at.year
      pu.save
    end
    change_column_null :progress_updates, :month, false
    change_column_null :progress_updates, :year, false
  end
  def down
    remove_column :progress_updates, :year
    remove_column :progress_updates, :month
  end
end
