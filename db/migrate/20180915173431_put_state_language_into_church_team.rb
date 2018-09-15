class PutStateLanguageIntoChurchTeam < ActiveRecord::Migration
  def up
    remove_reference :church_teams, :geo_state
    add_reference :church_teams, :state_language, index: true, foreign_key: true, null: false
  end
  def down
    remove_reference :church_teams, :state_language
    add_reference :church_teams, :geo_state, index: true, foreign_key: true, null: false
  end
end
