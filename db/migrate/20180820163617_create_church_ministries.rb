class CreateChurchMinistries < ActiveRecord::Migration
  def change
    create_table :church_ministries do |t|
      t.references :church_congregation, index: true, foreign_key: true, null: false
      t.references :ministry, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :church_ministries, [:church_congregation_id, :ministry_id], unique: true, name: 'index_church_ministry'
  end
end
