class ImproveUniqunessConstraintInChurchTeams < ActiveRecord::Migration
  def change
    add_index :church_teams, [:leader, :state_language_id], unique: true, where: 'organisation_id is NULL', name: 'index_church_team_unique_org_null'
  end
end
