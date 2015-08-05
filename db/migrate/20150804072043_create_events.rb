class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :user, index: true, foreign_key: true
      t.string :event_label, null: false
      t.date :event_date, null: false
      t.text :location
      t.integer :participant_amount
      t.integer :purpose
      t.text :content

      t.timestamps null: false
    end
  end
end
