class CreatePopulations < ActiveRecord::Migration
  def change
    create_table :populations do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.integer :amount, null: false
      t.string :source
      t.integer :year, index: true
      t.boolean :international, default: false, null: false
      t.text :note, null: true

      t.timestamps null: false
    end
  end
end
