require "test_helper"

describe LanguageStreamsController do

  let(:language_stream) { FactoryBot.build(:language_stream) }
  let(:admin_user) { FactoryBot.create(:user, admin: true) }

  it "should delete" do
    language_stream.save!
    ls_id = language_stream.id
    log_in_as(admin_user)
    delete :destroy, id: ls_id, format: :js
    value(response).must_be :success?
    _(LanguageStream).wont_be :exists?, ls_id
  end

end
