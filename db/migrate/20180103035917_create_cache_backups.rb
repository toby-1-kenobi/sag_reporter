class CreateCacheBackups < ActiveRecord::Migration
  def change
    create_table :cache_backups do |t|
      t.string :name, null: false, index: true, unique: true
      t.text :value
      t.datetime :expires, index: true

      t.timestamps null: false
    end
  end
end
