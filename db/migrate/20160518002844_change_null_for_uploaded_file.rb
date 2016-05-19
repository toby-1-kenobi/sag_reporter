class ChangeNullForUploadedFile < ActiveRecord::Migration
  def change
    change_column_null :uploaded_files, :report_id, true
  end
end
