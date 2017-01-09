require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  def setup
    @role = Role.new(name: 'Example Role')
  end

  test 'should be valid' do
    assert @role.valid?
  end

  test 'blank name is invalid' do
    @role.name = '     '
    assert_not @role.valid?
  end

  test 'role names should be unique' do
    duplicate_role = @role.dup
    @role.save
    assert_not duplicate_role.valid?
  end

  it 'can be destroyed without users' do
    value(@role).must_be :destroy
  end

  it 'wont be destroyed with users' do
    @role.users << User.new
    value(@role).wont_be :destroy
  end

end
