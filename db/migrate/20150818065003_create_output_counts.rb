class CreateOutputCounts < ActiveRecord::Migration
  def change
    create_table :output_counts do |t|
      t.belongs_to :output_tally, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :language, index: true, foreign_key: true, null:false
      t.integer :amount, null:false, default: 0
      t.integer :year, null: false
      t.integer :month, null: false

      t.timestamps null: false
    end
  end
end
