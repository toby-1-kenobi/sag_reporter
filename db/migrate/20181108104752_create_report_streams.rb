class CreateReportStreams < ActiveRecord::Migration
  def change
    create_table :report_streams do |t|
      t.references :report, index: true, foreign_key: true, null: false
      t.references :ministry, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :report_streams, [:report_id, :ministry_id], unique: true, name: 'index_report_ministry'
  end
end
