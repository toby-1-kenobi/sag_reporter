class CreateDistributionMethods < ActiveRecord::Migration
  def change
    create_table :distribution_methods do |t|
      t.string :name, null: false, index: true, unique: true

      t.timestamps null: false
    end
  end
end
