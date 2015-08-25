require "test_helper"

describe PeopleController do

  let(:fred) { Person.find_or_create_by(name: "Fred") }
  let(:wilma) { Person.find_or_create_by(name: "Wilma") }
  let(:barney) { Person.find_or_create_by(name: "Barney") }
  let(:betty) { Person.find_or_create_by(name: "betty") }

  let(:me) {
  	User.create(
  	  name: 'Toby',
  	  phone: '7777777777',
  	  password:              'password',
  	  password_confirmation: 'password',
  	  mother_tongue: Language.take,
  	  role: Role.find_by_name('admin')
  	)
  }

  before do
  	log_in_as(me)
  end

  it "gets people I've created as my contacts" do
  	fred.record_creator = me
  	fred.save
  	wilma.record_creator = me
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
  	_(ben.record_creator).must_equal me
  end

end
