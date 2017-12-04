class CreateGeoStates < ActiveRecord::Migration
  def change
    create_table :geo_states do |t|
      t.string :name, null: false, unique: true
      t.references :zone, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
