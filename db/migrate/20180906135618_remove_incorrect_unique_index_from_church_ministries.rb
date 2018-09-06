class RemoveIncorrectUniqueIndexFromChurchMinistries < ActiveRecord::Migration
  def up
    remove_index :church_ministries, name: 'index_church_ministry'
  end
  def down
    add_index :church_ministries, [:church_team_id, :ministry_id], unique: true, name: 'index_church_ministry'
  end
end
