class CreateTallyUpdates < ActiveRecord::Migration
  def change
    create_table :tally_updates do |t|
      t.references :languages_tally, index: true, foreign_key: true
      t.integer :amount, null: false, default: 0

      t.timestamps null: false
    end
  end
end
