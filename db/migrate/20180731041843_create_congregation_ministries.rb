class CreateCongregationMinistries < ActiveRecord::Migration
  def change
    create_table :congregation_ministries do |t|
      t.references :church_congregation, index: true, foreign_key: true, null: false
      t.references :ministry, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
