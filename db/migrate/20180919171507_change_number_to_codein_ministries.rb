class ChangeNumberToCodeinMinistries < ActiveRecord::Migration
  def up
    add_column :ministries, :code, :string, unique: true, index: true
    Ministry.all.each{ |m| m.update_attribute(:code, m.id.to_s) }
    change_column_null :ministries, :code, true
    remove_column :ministries, :number
    add_index :deliverables, [:number, :ministry_id], unique: true, name: 'index_deliverables_number_ministry'
  end
  def down
    add_column :ministries, :number, :integer
    Ministry.all.each{ |m| m.update_attribute(:number, m.id) }
    change_column_null :ministries, :number, true
    remove_column :ministries, :code
    remove_index :deliverables, name: 'index_deliverables_number_ministry'
  end
end
