class CreateChurchCongregations < ActiveRecord::Migration
  def change
    create_table :church_congregations do |t|
      t.string :name
      t.references :organisation, index: true, foreign_key: true
      t.references :village, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :church_congregations, [:organisation_id, :village_id], unique: true, name: 'index_village_church'
  end
end
