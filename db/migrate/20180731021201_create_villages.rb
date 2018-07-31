class CreateVillages < ActiveRecord::Migration
  def change
    create_table :villages do |t|
      t.string :name, index: true, null: false
      t.text :description, null: true
      t.references :geo_state, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
