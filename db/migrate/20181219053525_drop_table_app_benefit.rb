class DropTableAppBenefit < ActiveRecord::Migration
  def change
    drop_table :user_benefits do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :app_benefit, index: true, foreign_key: true, null: false

      t.timestamps null: false
      t.index [:user_id, :app_benefit_id], unique: true, name: 'index_user_benefit'
    end
    drop_table :app_benefits do |t|
      t.string :name, index: true, null: false

      t.timestamps null: false
    end
  end
end
