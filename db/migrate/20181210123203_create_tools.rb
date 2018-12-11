class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :creator, index: true, null: false
      t.text :url, null: false
      t.text :description, null: false
      t.integer :status, null: false, default: 0

      t.timestamps null: false
    end
    add_foreign_key :tools, :users, column: 'creator_id'
  end
end
