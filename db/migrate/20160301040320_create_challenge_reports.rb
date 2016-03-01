class CreateChallengeReports < ActiveRecord::Migration
  def change
    create_table :challenge_reports do |t|
      t.integer :status
      t.timestamps null: false
    end
  end
end
