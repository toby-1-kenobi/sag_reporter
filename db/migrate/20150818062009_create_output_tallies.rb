class CreateOutputTallies < ActiveRecord::Migration
  def change
    create_table :output_tallies do |t|
      t.belongs_to :topic, index: true, foreign_key: true, null:false
      t.string :name, unique: true, null: false
      t.text :description

      t.timestamps null: false
    end
  end
end
