require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

  def setup
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
    @admin_user = FactoryBot.create(:user, admin: true)
  end

  test "should get home" do
  	log_in_as(@admin_user)
    get :home
    assert_response :success
    assert_select "title", "LCI App Home | LCI App"
  end

end
