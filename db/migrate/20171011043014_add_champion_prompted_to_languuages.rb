class AddChampionPromptedToLanguuages < ActiveRecord::Migration
  def change
    add_column :languages, :champion_prompted, :datetime, null: true
  end
end
