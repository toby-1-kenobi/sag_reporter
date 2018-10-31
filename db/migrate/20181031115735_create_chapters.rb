class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.references :book, index: true, foreign_key: true
      t.integer :number, null: false, index: true
      t.integer :verses, null: false

      t.timestamps null: false
    end
  end
end
