class LinkChurchTeamToReports < ActiveRecord::Migration
  def up
    add_reference :reports, :church_team, index: true, foreign_key: true, null: true
    remove_reference :reports, :church_ministry
  end
  def down
    remove_reference :reports, :church_team
    add_reference :reports, :church_ministry, index: true, foreign_key: true, null: true
  end
end
