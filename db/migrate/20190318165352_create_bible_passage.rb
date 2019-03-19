class CreateBiblePassage < ActiveRecord::Migration
  def change
    create_table :bible_passages do |t|
      t.references :church_ministry, index: true, foreign_key: true, null: false
      t.references :chapter, index: true, foreign_key: true, null: false
      t.string :month, null: false
      t.integer :verse, null: false
    end
  end
end
