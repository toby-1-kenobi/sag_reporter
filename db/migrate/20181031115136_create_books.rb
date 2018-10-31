class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name, null: false, unique: true
      t.string :abbreviation, null: false, unique: true
      t.integer :number, null: false, index: true, unique: true
      t.boolean :nt, null: false, index: true

      t.timestamps null: false
    end
  end
end
