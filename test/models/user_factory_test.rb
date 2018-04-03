require "test_helper"

describe User::Factory do

  let(:factory) { User::Factory.new }
  let(:role) { Role.new name: "test_role" }
  let(:language) { Language.new name: "test_language" }
  let(:state_a) { GeoState.new name: "State A"}
  let(:state_b) { GeoState.new name: "State B"}
  let(:user) { User.new(
      name: "Test User", 
      phone: "9876543210", 
      password_digest: User.digest('password'),
      mother_tongue_id: 5) }

  it "makes valid users" do
    user_params = {
      name: "Test User", 
      phone: "9876543210", 
      password: "foobar", 
      password_confirmation: "foobar",
      mother_tongue_id: 5,
      geo_states: [geo_states(:nb).id]
    }
    _(factory.build_user(user_params)).must_equal true
    _(factory.instance()).must_be :valid?
  end

  it "makes valid users with db relationships" do
    user_params = {
      name: "Test User", 
      phone: "9876543210",  
      password: "foobar", 
      password_confirmation: "foobar",
      mother_tongue: language,
      speaks: [1],
      geo_states: [2, 3]
    }
    GeoState.stubs(:find).with(2).returns state_a
    GeoState.stubs(:find).with(3).returns state_b
    Language.stub :find, language do
      factory.build_user(user_params)
    end
    _(factory.instance().spoken_languages.length).must_be :>, 0
    _(factory.instance().geo_states.length).must_equal 2
  end

  it "fails gracefully when creating with bad parameters" do
    user_params = {
      name: "Test User", 
      phone: "9876543210", 
      password: "foobar", 
      password_confirmation: "wrong!"
    }
    _(factory.create_user(user_params)).must_equal false
  end

  it "fails gracefully with unknown parameters" do
    user_params = {
      name: "Test User", 
      what: "huh?"
    }
    _(factory.build_user(user_params)).must_equal false
  end

  it "makes sure the mother-tongue is included in spoken languages" do
    user_params = {
      name: "Test User", 
      phone: "9876543210", 
      password: "foobar", 
      password_confirmation: "foobar",
      mother_tongue: language
    }
    _(factory.build_user(user_params)).must_equal true
    _(factory.instance().spoken_languages).must_include language
  end

end
