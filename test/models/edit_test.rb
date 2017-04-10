require "test_helper"

describe Edit do
  let(:language) { languages(:assamese) }
  let(:admin_user) { users(:andrew) }
  let(:edit) { Edit.new(
      user: admin_user,
      table_name: 'languages',
      field_name: 'name',
      record_id: language.id,
      old_value: language.name,
      new_value: 'new name'
  ) }

  it 'must be valid' do
    puts "lang id: #{language.id}"
    value(edit).must_be :valid?
  end
end
