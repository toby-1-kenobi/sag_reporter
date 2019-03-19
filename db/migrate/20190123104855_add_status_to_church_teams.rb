class AddStatusToChurchTeams < ActiveRecord::Migration
  def up
    add_column :church_teams, :status, :integer, null: false, default: 0
  end

  def down
    remove_column :church_teams, :status
  end
end
