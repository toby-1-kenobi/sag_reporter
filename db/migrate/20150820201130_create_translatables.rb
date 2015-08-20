class CreateTranslatables < ActiveRecord::Migration
  def change
    create_table :translatables do |t|
      t.string :identifier, null: false, unique: true
      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
