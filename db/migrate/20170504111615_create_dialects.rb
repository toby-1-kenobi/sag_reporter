class CreateDialects < ActiveRecord::Migration
  def change
    create_table :dialects do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    add_index :dialects, [:language_id, :name], unique: true, name: 'language_dialect_names'
  end
end
