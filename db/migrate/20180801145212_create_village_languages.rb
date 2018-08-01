class CreateVillageLanguages < ActiveRecord::Migration
  def change
    create_table :village_languages do |t|
      t.references :village, index: true, foreign_key: true, null: false
      t.references :language, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :village_languages, [:village_id, :language_id], unique: true, name: 'index_village_lang'
  end
end
