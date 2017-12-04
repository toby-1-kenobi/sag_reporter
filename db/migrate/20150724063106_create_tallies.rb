class CreateTallies < ActiveRecord::Migration
  def change
    create_table :tallies do |t|
      t.string :name
      t.text :description
      t.integer :state, null: false, default: 1, index: true
      t.references :topic, index: true

      t.timestamps null: false
    end
    add_foreign_key :tallies, :topics
  end
end
