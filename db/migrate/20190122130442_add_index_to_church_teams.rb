class AddIndexToChurchTeams < ActiveRecord::Migration
  def change
    add_index :church_teams, [:leader, :state_language_id, :organisation_id], unique: true, name: 'index_church_team_unique'
  end
end
