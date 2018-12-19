class DropTableActionPoints < ActiveRecord::Migration
  def up
    drop_table :action_points
  end
  def down
    create_table :action_points do |t|
      t.text :content, null: false
      t.belongs_to :responsible, null: false, index: true, references: :people
      t.integer :status, null: false, default: 0
      t.belongs_to :record_creator, index: true, references: :users
      t.belongs_to :event, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_foreign_key :action_points, :people, column: :responsible_id
    add_foreign_key :action_points, :users, column: :record_creator_id
  end
end
