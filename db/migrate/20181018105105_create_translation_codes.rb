class CreateTranslationCodes < ActiveRecord::Migration
  def up
    create_table :translation_codes do |t|
      t.timestamps null: false
    end
  end
  def down
    drop_table :translation_codes, force: :cascade
  end
end
