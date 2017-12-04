class AddStatusToReport < ActiveRecord::Migration

  def up
    add_column :reports, :status, :integer, null: false, default: 0
    remove_column :reports, :state
  end

  def down
    add_column :reports, :state, :integer, null: false, default: 1
    remove_column :reports, :status
  end

end
