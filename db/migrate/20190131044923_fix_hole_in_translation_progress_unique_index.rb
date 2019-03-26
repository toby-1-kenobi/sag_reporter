class FixHoleInTranslationProgressUniqueIndex < ActiveRecord::Migration
  def up
    remove_index :translation_progresses, name: 'index_translation_progress_unique'
    add_index :translation_progresses, [:chapter_id, :language_id, :deliverable_id], unique: true, name: 'index_translation_progress_unique'
  end
  def down
    remove_index :translation_progresses, name: 'index_translation_progress_unique'
    add_index :translation_progresses, [:chapter_id, :language_id, :deliverable_id, :month], unique: true, name: 'index_translation_progress_unique'
  end
end
