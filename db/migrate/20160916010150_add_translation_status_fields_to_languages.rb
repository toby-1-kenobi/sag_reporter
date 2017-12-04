class AddTranslationStatusFieldsToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :translation_need, :integer, null: false, default: 0
    add_column :languages, :translation_progress, :integer, null: false, default: 0
    add_index :languages, :translation_need
    add_index :languages, :translation_progress
  end
end
