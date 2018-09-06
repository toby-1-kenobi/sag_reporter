require 'test_helper'

class TopicsControllerTest < ActionController::TestCase

  def setup
    @admin_user = FactoryBot.create(:user, admin: true)
    @pleb_user = FactoryBot.create(:user)
    @education = FactoryBot.create(:topic, name: 'social development')
  end

end
