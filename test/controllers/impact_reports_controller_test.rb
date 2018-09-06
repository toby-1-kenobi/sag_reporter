require "test_helper"

describe ImpactReportsController do

  let (:trusted_user) { FactoryBot.create(:user, trusted: true) }
  let (:untrusted_user) { FactoryBot.create(:user, trusted: false) }
  let (:impact_report) { FactoryBot.create(:impact_report) }

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
  end

end
