class MoveTranslationProgressFromLanguageToTranslationProject < ActiveRecord::Migration
  def up
    remove_index :translation_progresses, name: 'index_translation_progress_unique'
    add_reference :translation_progresses, :translation_project, index: true, foreign_key: true, null: false
    remove_reference :translation_progresses, :language
    add_index :translation_progresses, [:chapter_id, :translation_project_id, :deliverable_id], unique: true, name: 'index_translation_progress_unique'
  end
  def down
    remove_index :translation_progresses, name: 'index_translation_progress_unique'
    add_reference :translation_progresses, :language, index: true, foreign_key: true
    remove_reference :translation_progresses, :translation_project
    add_index :translation_progresses, [:chapter_id, :language_id, :deliverable_id], unique: true, name: 'index_translation_progress_unique'
  end
end
