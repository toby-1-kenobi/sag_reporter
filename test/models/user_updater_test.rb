require "test_helper"

describe User::Updater do

  let(:updater) { User::Updater.new(user) }
  let(:role) { Role.new name: "test_role" }
  let(:language) { Language.new name: "test_language" }
  let(:user) { User.new(
      name: "Test User", 
      phone: "9876543210", 
      password_digest: User.digest('password'),
      role_id: 3,
      mother_tongue_id: 5,
      geo_states: [geo_states(:nb)]) }

  it "updates users" do
    user_params = {
      name: "Test User Updated", 
      phone: "9876543220", 
      password: "foobar", 
      password_confirmation: "foobar",
      role_id: 3,
      mother_tongue_id: 5
    }
    _(updater.update_user(user_params)).must_equal true
    _(updater.instance().name).must_equal "Test User Updated"
  end

  it "makes sure the mother-tongue is included in spoken languages" do
    db_language = Language.take
    user_params = {
      name: "Test User", 
      phone: "9876543210", 
      password: "foobar", 
      password_confirmation: "foobar",
      role_id: 3,
      mother_tongue: db_language
    }
    updater.update_user(user_params)
    _(updater.instance().spoken_languages).must_include db_language
  end

end