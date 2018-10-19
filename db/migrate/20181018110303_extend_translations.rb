class ExtendTranslations < ActiveRecord::Migration
  def up
    add_reference :translations, :translation_code, index: true, foreign_key: true, null: true
  end
  def down
    remove_reference :translations, :translation_code
  end
end
