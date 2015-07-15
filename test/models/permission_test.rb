require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  def setup
    @perm = Permission.new(name: "example_permission", description: "Example for test")
  end

  test "should be valid" do
    assert  @perm.valid?
  end

  test "blank name is invalid" do
    @perm.name = "     "
    assert_not  @perm.valid?
  end

  test "permissions should be unique" do
    duplicate_perm =  @perm.dup
    @perm.save
    assert_not duplicate_perm.valid?
  end

end
