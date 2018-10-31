class CreateTranslationProgresses < ActiveRecord::Migration
  def change
    create_table :translation_progresses do |t|
      t.references :language, index: true, foreign_key: true
      t.references :chapter, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :translation_progresses, [:language_id, :chapter_id], unique: true, name: 'index_language_chapter'
  end
end
