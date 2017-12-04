class AddRelationshipToEdits < ActiveRecord::Migration
  def change
    add_column :edits, :relationship, :boolean, default: false, null: false
  end
end
