class DropOutputTalliesAndCounts < ActiveRecord::Migration
  def change
    drop_table :output_counts do |t|
      t.belongs_to :output_tally, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :language, index: true, foreign_key: true, null:false
      t.integer :amount, null:false, default: 0
      t.integer :year, null: false
      t.integer :month, null: false

      t.timestamps null: false
    end
    drop_table :output_tallies do |t|
      t.belongs_to :topic, index: true, foreign_key: true, null:false
      t.string :name, unique: true, null: false
      t.text :description

      t.timestamps null: false
    end
  end
end
