class CreateLanguagesTallies < ActiveRecord::Migration
  def change
    create_table :languages_tallies do |t|
      t.references :language, index: true, foreign_key: true
      t.references :tally, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
