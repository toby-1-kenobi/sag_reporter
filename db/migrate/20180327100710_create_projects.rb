class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name, null:false, unique:true, index:true

      t.timestamps null: false
    end
  end
end
