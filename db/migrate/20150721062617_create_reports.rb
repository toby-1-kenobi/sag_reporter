class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :reporter, null: false
      t.text :content
      t.integer :type, null: false, default: 0
      t.integer :state, null: false,default: 1

      t.timestamps null: false
    end
    add_index :reports, :reporter
    add_index :reports, :type
    add_index :reports, :state
  end
end
