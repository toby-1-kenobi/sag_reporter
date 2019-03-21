class CreateTranslationDistributions < ActiveRecord::Migration
  def change
    create_table :translation_distributions do |t|
      t.references :distribution_method, index: true, foreign_key: true, null: false
      t.references :language, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :translation_distributions, [:distribution_method_id, :language_id], unique: true, name: 'index_translation_distribution_uniq'
  end
end
