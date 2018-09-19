class CreateAggregateMinistryOutputs < ActiveRecord::Migration
  def change
    create_table :aggregate_ministry_outputs do |t|
      t.references :aggregate_deliverable, index: true, foreign_key: true, null: false
      t.string :month, null: false
      t.integer :value, null: false
      t.boolean :actual, null: false
      t.references :language_stream, index: true, foreign_key: true, null: false
      t.references :creator, index: true, null: false
      t.text :comment

      t.timestamps null: false
    end
    add_foreign_key :aggregate_ministry_outputs, :users, column: 'creator_id'
  end
end
