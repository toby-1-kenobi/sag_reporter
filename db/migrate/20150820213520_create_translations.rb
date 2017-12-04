class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.belongs_to :translatable, index: true, foreign_key: true, null: true
      t.references :language, index: true, foreign_key: true, null: true
      t.text :content

      t.timestamps null: false
    end
  end
end
