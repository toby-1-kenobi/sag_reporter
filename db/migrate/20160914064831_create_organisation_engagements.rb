class CreateOrganisationEngagements < ActiveRecord::Migration
  def change
    create_table :organisation_engagements do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :organisation, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :organisation_engagements, [:language_id, :organisation_id], unique: true, name: 'index_orgs_languages'
  end
end
