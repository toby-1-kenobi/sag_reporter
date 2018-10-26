class DropTranslatables < ActiveRecord::Migration
  def change
    drop_table :translatables do |t|
      t.string :identifier, null: false, unique: true, index: true
      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
