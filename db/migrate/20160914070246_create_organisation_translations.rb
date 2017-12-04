class CreateOrganisationTranslations < ActiveRecord::Migration
  def change
    create_table :organisation_translations do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :organisation, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :organisation_translations, [:language_id, :organisation_id], unique: true, name: 'index_orgs_languages_trans'
  end
end
