class CreateMtResources < ActiveRecord::Migration
  def change
    create_table :mt_resources do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.belongs_to :language, index: true, foreign_key: true, null: false
      t.boolean :cc_share_alike, null: false, default: false
      t.integer :type, null: false, index: true

      t.timestamps null: false
    end
  end
end
