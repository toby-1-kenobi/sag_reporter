class DropTallies < ActiveRecord::Migration
  def change
    drop_table :tally_updates
    drop_table :languages_tallies
    drop_table :tallies
  end
end
