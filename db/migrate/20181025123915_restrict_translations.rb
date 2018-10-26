class RestrictTranslations < ActiveRecord::Migration
  def up
    change_column_null :translations, :translation_code_id, false
    change_column_null :translations, :language_id, false
    change_column_null :translations, :content, false
    remove_reference :translations, :translatable
    add_index :translations, [:language_id, :translation_code_id], unique: true, name: 'index_language_translation_code'
  end
  def down
    change_column_null :translations, :translation_code_id, true
    change_column_null :translations, :language_id, true
    change_column_null :translations, :content, true
    add_reference :translations, :translatable, index: true, foreign_key: true, null: true
    remove_index :translations, name: "index_language_translation_code"
  end
end
