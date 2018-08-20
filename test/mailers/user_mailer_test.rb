
require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  let(:user) { FactoryBot.build(:user) }
  let(:language) { Language.new name: 'prompt due', updated_at: 31.days.ago, champion: user }

  it 'updates the language champion prompt date when prompting language champions' do
    language.save
    UserMailer.prompt_champion(user, [[language, 31.days.ago]]).deliver_now
    language.reload
    _(language.champion_prompted).must_be :present?
  end

end