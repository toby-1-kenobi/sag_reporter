class DropFacilitatorsTable < ActiveRecord::Migration
  def change
    drop_table :facilitator_languages do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :facilitator, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    drop_table :facilitator_streams do |t|
      t.references :ministry, index: true, foreign_key: true, null: false
      t.references :facilitator, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    drop_table :facilitators do |t|
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
