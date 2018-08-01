class CreateVillageLanguages < ActiveRecord::Migration
  def change
    create_table :village_languages do |t|
      t.references :village, index: true, foreign_key: true, null: false
      t.references :language, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
