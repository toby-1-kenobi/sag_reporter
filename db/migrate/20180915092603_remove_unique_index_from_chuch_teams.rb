class RemoveUniqueIndexFromChuchTeams < ActiveRecord::Migration
  def up
    remove_index :church_teams, name: 'index_village_church'
  end
  def down
    add_index :church_teams, [:organisation_id, :village], unique: true, name: 'index_village_church'
  end
end
