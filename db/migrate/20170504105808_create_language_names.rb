class CreateLanguageNames < ActiveRecord::Migration
  def change
    create_table :language_names do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.string :name, null: false, index: true
      t.boolean :preferred, default: false, null: false
      t.boolean :used_by_speakers, default: false, null: false
      t.boolean :used_by_outsiders, default: false, null: false

      t.timestamps null: false
    end
    add_index :language_names, [:language_id, :name], unique: true, name: 'uniq_language_names'
  end
end
