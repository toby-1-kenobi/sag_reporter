class AddCuratorPromptedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :curator_prompted, :datetime, null: true
  end
end
