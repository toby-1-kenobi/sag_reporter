class AddShortFormToMinistries < ActiveRecord::Migration
  def up
    add_reference :ministries, :short_form, index: true
    add_foreign_key :ministries, :translation_codes, column: :short_form_id
    Ministry.all.each{ |m| m.update short_form: TranslationCode.create }
    change_column_null :ministries, :short_form_id, false
  end
  def down
    remove_reference :ministries, :short_form
  end
end
