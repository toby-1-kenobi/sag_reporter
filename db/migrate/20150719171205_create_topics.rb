class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.text :description
      t.string :colour, null: false, default: "white"

      t.timestamps null: false
    end
  end
end
