class AddCuratorPromptedToEdits < ActiveRecord::Migration
  def change
    add_column :edits, :curator_prompted, :datetime, null: true
  end
end
