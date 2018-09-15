class MakeFacilitatorOptionalInChurchMinistries < ActiveRecord::Migration
  def change
    change_column_null :church_ministries, :facilitator_id, false
  end
end
