class RenameVillageToLeaderInChurchTeams < ActiveRecord::Migration
  def change
    rename_column :church_teams, :village, :leader
  end
end
