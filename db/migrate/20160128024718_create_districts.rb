class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :name, index:true, null: false
      t.references :geo_state, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
