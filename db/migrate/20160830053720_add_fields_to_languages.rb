class AddFieldsToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :iso, :string, limit: 3
    add_index :languages, :iso, unique: true
    add_reference :languages, :family, index: true, references: :language_families
    add_foreign_key :languages, :language_families, column: :family_id
    add_column :languages, :population, :integer, limit: 8
    add_reference :languages, :pop_source, index: true, references: :data_sources
    add_foreign_key :languages, :data_sources, column: :pop_source_id
    add_column :languages, :location, :text
    add_column :languages, :number_of_translations, :integer
    add_reference :languages, :cluster, index: true, foreign_key: true
    add_column :languages, :info, :text
  end
end
