class FixHoleInTranslationProgressUniqueIndex < ActiveRecord::Migration
  def change
    add_index :translation_progresses, [:chapter_id, :language_id, :deliverable_id], unique: true, where: 'month IS NULL', name: 'index_translation_progress_uniq_month_null'
  end
end
