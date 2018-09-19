class CreateAggregateDeliverables < ActiveRecord::Migration
  def change
    create_table :aggregate_deliverables do |t|
      t.references :ministry, index: true, foreign_key: true, null: false
      t.integer :number, null: false

      t.timestamps null: false
    end
  end
end
