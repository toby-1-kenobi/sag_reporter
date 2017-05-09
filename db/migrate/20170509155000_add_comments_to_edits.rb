class AddCommentsToEdits < ActiveRecord::Migration
  def change
    add_column :edits, :creator_comment, :text
    add_column :edits, :curator_comment, :text
  end
end
