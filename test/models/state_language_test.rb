require "test_helper"

describe StateLanguage do
  let(:state_language) { StateLanguage.new geo_state: geo_states(:nb), language: languages(:toto) }

  it "must be valid" do
    value(state_language).must_be :valid?
  end

  it "is sortable by language name" do
    sl_santali = StateLanguage.new language: languages(:santali)
    _([state_language, sl_santali].sort!).must_equal [sl_santali, state_language]
  end

  it "makes a table of outcome scores" do
    start_date = Date.new(2015,7,1)
    end_date = Date.new(2015,12,1)
    pm_social1 = progress_markers(:skills_used)
    pm_social2 = progress_markers(:new_initiatives)
    pm_leader = progress_markers(:devotional)
    social_oa = pm_social1.topic
    leader_oa = pm_leader.topic
    lp_social1 = LanguageProgress.new progress_marker: pm_social1
    lp_social2 = LanguageProgress.new progress_marker: pm_social2
    lp_leader = LanguageProgress.new progress_marker: pm_leader

    lp_social1.stubs(:outcome_scores).with(start_date, end_date).returns({"October 2015" => 1})
    lp_social2.stubs(:outcome_scores).with(start_date, end_date).returns({"October 2015" => 2, "November 2015" => 8})
    lp_leader.stubs(:outcome_scores).with(start_date, end_date).returns({"October 2015" => 4})

    state_language.language_progresses << [lp_social1, lp_social2, lp_leader]
    state_language.language_progresses.stubs(:includes).returns state_language.language_progresses
    table = state_language.outcome_table_data(from_date: start_date, to_date: end_date)

    value(table[social_oa.name]["October 2015"]).must_equal 3
    value(table[leader_oa.name]["October 2015"]).must_equal 4
    value(table[social_oa.name]["November 2015"]).must_equal 8
    value(table["Totals"]["October 2015"]).must_equal 7
  end

end
