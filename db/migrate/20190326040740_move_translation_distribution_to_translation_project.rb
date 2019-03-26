class MoveTranslationDistributionToTranslationProject < ActiveRecord::Migration
  def up
    add_reference :translation_distributions, :translation_project, index: true, foreign_key: true, null: false
    remove_reference :translation_distributions, :language
    add_index :translation_distributions, [:distribution_method_id, :translation_project_id], unique: true, name: 'index_translation_distribution_uniq'
  end
  def down
    add_reference :translation_distributions, :language, index: true, foreign_key: true, null: false
    remove_reference :translation_distributions, :translation_project
    add_index :translation_distributions, [:distribution_method_id, :language_id], unique: true, name: 'index_translation_distribution_uniq'
  end
end
