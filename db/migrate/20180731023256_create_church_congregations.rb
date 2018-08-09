class CreateChurchCongregations < ActiveRecord::Migration
  def change
    create_table :church_congregations do |t|
      t.string :name
      t.references :organisation, index: true, foreign_key: true
      t.string :village, index: true, null: false

      t.timestamps null: false
    end
    add_index :church_congregations, [:organisation_id, :village], unique: true, name: 'index_village_church'
  end
end
