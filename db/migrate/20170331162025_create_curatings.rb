class CreateCuratings < ActiveRecord::Migration
  def change
    create_table :curatings do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :geo_state, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
