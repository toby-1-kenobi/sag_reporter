class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.text :description
      t.string :phone
      t.text :address
      t.boolean :intern
      t.boolean :facilitator
      t.boolean :pastor
      t.references :language, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
