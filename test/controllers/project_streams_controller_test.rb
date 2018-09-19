require "test_helper"

describe ProjectStreamsController do

  let(:project_stream) { FactoryBot.build(:project_stream) }
  let(:admin_user) { FactoryBot.create(:user, admin: true) }

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
  end

  it "should set supervisor" do
    project_stream.save!
    log_in_as(admin_user)
    patch :set_supervisor, format: :js, id: project_stream.id, supervisor: admin_user.id
    value(response).must_be :success?
    project_stream.reload
    _(project_stream.supervisor_id).must_equal admin_user.id
  end

end
