require "test_helper"

describe PeopleController do

  let(:fred) { Person.find_or_create_by(name: "Fred") }
  let(:wilma) { Person.find_or_create_by(name: "Wilma") }
  let(:barney) { Person.find_or_create_by(name: "Barney") }
  let(:betty) { Person.find_or_create_by(name: "betty") }

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
  end

  let(:admin_user) {
  	User.create(
  	  name: 'Toby',
  	  phone: '7777777777',
  	  password:              'password',
  	  password_confirmation: 'password',
      geo_states: [FactoryBot.create(:geo_state)]
  	)
  }

  before do
  	log_in_as(admin_user)
  end

  it "gets people I've created as my contacts" do
  	fred.record_creator = admin_user
  	fred.save
  	wilma.record_creator = admin_user
  	wilma.save
  	get :index
  	must_respond_with :success
  	must_render_template :index
  	_(assigns(:people)).wont_be_empty
  end

  it "creates a new person with current user as record_creator" do
  	post :create, person: {name: "Ben"}
  	must_respond_with :redirect
  	ben = Person.find_by_name("Ben")
  	_(ben.record_creator).must_equal admin_user
  end

end
