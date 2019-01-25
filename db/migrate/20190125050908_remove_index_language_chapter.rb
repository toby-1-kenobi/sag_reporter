class RemoveIndexLanguageChapter < ActiveRecord::Migration
  def change
    remove_index :translation_progresses, name: 'index_language_chapter'
  end
end
