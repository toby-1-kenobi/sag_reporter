require 'test_helper'

describe StateLanguage do
  let(:state_language) { StateLanguage.new geo_state: geo_states(:nb), language: languages(:toto) }
  let(:admin_user) { users(:andrew) }

  it 'must be valid' do
    value(state_language).must_be :valid?
  end

  it 'is sortable by language name' do
    sl_santali = StateLanguage.new language: languages(:santali)
    _([state_language, sl_santali].sort!).must_equal [sl_santali, state_language]
  end

  it 'makes a table of outcome scores' do
    start_date = Date.new(2015,7,1)
    end_date = Date.new(2015,12,1)
    pm_social1 = progress_markers(:skills_used) # weight 2
    pm_social2 = progress_markers(:new_initiatives) # weight 2
    pm_leader = progress_markers(:devotional) # weight 1
    social_oa = pm_social1.topic
    leader_oa = pm_leader.topic
    lp_social1 = LanguageProgress.new progress_marker: pm_social1
    lp_social2 = LanguageProgress.new progress_marker: pm_social2
    lp_leader = LanguageProgress.new progress_marker: pm_leader

    lp_social1.stubs(:outcome_scores).with(start_date, end_date).returns({'October 2015' => 1})
    lp_social2.stubs(:outcome_scores).with(start_date, end_date).returns({'October 2015' => 2, 'November 2015' => 8})
    lp_leader.stubs(:outcome_scores).with(start_date, end_date).returns({'October 2015' => 4})

    state_language.language_progresses << [lp_social1, lp_social2, lp_leader]
    state_language.language_progresses.stubs(:includes).returns state_language.language_progresses
    max_scores = {social_oa.id => 12, leader_oa.id => 3}
    state_language.stubs(:max_outcome_scores).returns max_scores
    table = state_language.outcome_table_data(admin_user, from_date: start_date, to_date: end_date)

    value(table['content'][social_oa.name]['October 2015']).must_equal 300.fdiv(12)
    value(table['content'][leader_oa.name]['October 2015']).must_equal 400.fdiv(3)
    value(table['content'][social_oa.name]['November 2015']).must_equal 800.fdiv(12)
    #value(table["Totals"]["October 2015"]).must_equal 7
  end

  it 'calculates maximum attainable outcome scores for used pms' do
    pm_social1 = progress_markers(:skills_used) # weight 2
    pm_social2 = progress_markers(:new_initiatives) # weight 2
    pm_leader = progress_markers(:devotional) # weight 1
    faith_oa = progress_markers(:prayer).topic
    social_oa = pm_social1.topic
    leader_oa = pm_leader.topic
    state_language.save!
    lp_social1 = state_language.language_progresses.create! progress_marker: pm_social1
    lp_social2 = state_language.language_progresses.create! progress_marker: pm_social2
    lp_leader = state_language.language_progresses.create! progress_marker: pm_leader
    lp_social1.progress_updates.create! progress: 1, month: 1, year: 2015, user: users(:andrew)
    lp_social2.progress_updates.create! progress: 1, month: 1, year: 2015, user: users(:andrew)
    lp_leader.progress_updates.create! progress: 1, month: 1, year: 2015, user: users(:andrew)

    max_scores = state_language.max_outcome_scores
    value(max_scores[social_oa.id]).must_equal 12 # (2 + 2) * 3 total weight times max level (3)
    value(max_scores[leader_oa.id]).must_equal 3 # 1 * 3
    value(max_scores[faith_oa.id]).must_equal 0 # not used
  end

  it 'returns nil when asked for a table where there is no progress updates' do
    start_date = Date.new(2015,7,1)
    end_date = Date.new(2015,12,1)
    _(state_language.outcome_table_data(admin_user, from_date: start_date, to_date: end_date)).must_be_nil
  end

end
