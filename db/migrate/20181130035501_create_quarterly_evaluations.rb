class CreateQuarterlyEvaluations < ActiveRecord::Migration
  def change
    create_table :quarterly_evaluations do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :sub_project, index: true, foreign_key: true, null: true
      t.references :state_language, index: true, foreign_key: true, null: false
      t.references :ministry, index: true, foreign_key: true, null: false
      t.string :quarter, index: true, null: false
      t.text :comment, null: true
      t.text :question_1, null: true
      t.text :question_2, null: true
      t.text :question_3, null: true
      t.text :question_4, null: true
      t.integer :progress, null: true
      t.references :report, index: true, foreign_key: true, null: true
      t.boolean :approved, null: false, default: false

      t.timestamps null: false
    end
  end
end
