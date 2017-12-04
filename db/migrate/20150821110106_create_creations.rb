class CreateCreations < ActiveRecord::Migration
  def change
    create_table :creations do |t|
      t.references :person, index: true, foreign_key: true
      t.references :mt_resource, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :creations, [:person_id, :mt_resource_id], unique: true, name: 'index_people_mt_resources'
  end
end
