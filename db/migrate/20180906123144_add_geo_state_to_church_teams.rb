class AddGeoStateToChurchTeams < ActiveRecord::Migration
  def change
    add_reference :church_teams, :geo_state, index: true, foreign_key: true
  end
end
