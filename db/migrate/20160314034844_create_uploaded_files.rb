class CreateUploadedFiles < ActiveRecord::Migration
  def change
    create_table :uploaded_files do |t|
      t.references :report, index: true, foreign_key: true, null: false
      t.string :ref, null: false

      t.timestamps null: false
    end
  end
end
