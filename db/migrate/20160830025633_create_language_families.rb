class CreateLanguageFamilies < ActiveRecord::Migration
  def change
    create_table :language_families do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    # enforce uniqueness in language family names
    add_index :language_families, :name, unique: true
  end
end
