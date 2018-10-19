class LinkColumnsToTranslationCodes < ActiveRecord::Migration
  def up
    add_reference :deliverables, :short_form, index: true
    add_foreign_key :deliverables, :translation_codes, column: :short_form_id
    add_reference :deliverables, :plan_form, index: true
    add_foreign_key :deliverables, :translation_codes, column: :plan_form_id
    add_reference :deliverables, :result_form, index: true
    add_foreign_key :deliverables, :translation_codes, column: :result_form_id
    add_reference :ministries, :name, index: true
    add_foreign_key :ministries, :translation_codes, column: :name_id
    Ministry.all.each{ |m| m.update name: TranslationCode.create }
    Deliverable.all.each do |d|
      d.update short_form: TranslationCode.create
      d.update plan_form: TranslationCode.create
      d.update result_form: TranslationCode.create
    end
    change_column_null :deliverables, :short_form_id, false
    change_column_null :deliverables, :plan_form_id, false
    change_column_null :deliverables, :result_form_id, false
    change_column_null :ministries, :name_id, false
  end
  def down
    remove_reference :deliverables, :short_form
    remove_reference :deliverables, :plan_form
    remove_reference :deliverables, :result_form
    remove_reference :ministries, :name
  end
end
