class RemoveIndexLanguageChapter < ActiveRecord::Migration
  def up
    remove_index :translation_progresses, name: 'index_language_chapter'
  end
  def down
    add_index :translation_progresses, [:language_id, :chapter_id], unique: true, name: 'index_language_chapter'
  end
end
