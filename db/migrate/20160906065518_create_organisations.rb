class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :abbreviation
      t.belongs_to :parent, references: :organisations

      t.timestamps null: false
    end
    add_foreign_key :organisations, :organisations, column: :parent_id
    add_index :organisations, :name, unique: true
    add_index :organisations, :abbreviation, unique: true
  end
end
