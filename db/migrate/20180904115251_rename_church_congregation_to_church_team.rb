class RenameChurchCongregationToChurchTeam < ActiveRecord::Migration
  def change
    rename_table :church_congregations, :church_teams
    rename_column :church_ministries, :church_congregation_id, :church_team_id
    rename_column :users, :church_congregation_id, :church_team_id
  end
end
