require 'test_helper'

describe LanguageProgress do
  let(:language_progress) { LanguageProgress.new progress_marker: pm, state_language: sl }
  let(:pm) { ProgressMarker.new name: 'test pm', topic: topics(:language_development)}
  let(:sl) { StateLanguage.new }
  let(:pu1) { ProgressUpdate.new progress: 2,
                                 year:2015,
                                 month: 8,
                                 language_progress: language_progress,
                                 geo_state: geo_states(:nb),
                                 user: users(:andrew) }
  let(:pu2) { ProgressUpdate.new progress: 3,
                                 year:2015,
                                 month: 10,
                                 language_progress: language_progress,
                                 geo_state: geo_states(:nb),
                                 user: users(:andrew) }

  it 'must be valid' do
    value(language_progress).must_be :valid?
  end

  it 'wont be valid without a progress marker' do
    language_progress.progress_marker = nil
    language_progress.valid?
    _(language_progress.errors[:progress_marker]).must_be :any?
  end

  it 'wont be valid without a state_language' do
    language_progress.state_language = nil
    language_progress.valid?
    _(language_progress.errors[:state_language]).must_be :any?
  end

  it 'must have a unique progress marker within each state_language' do
    language_progress.save
    language_progress2 = LanguageProgress.new progress_marker: pm, state_language: sl
    language_progress2.valid?
    _(language_progress2.errors[:progress_marker]).must_be :any?
  end

  it 'may have non-unique progress marker with different state_language' do
    language_progress.save
    language_progress2 = LanguageProgress.new(progress_marker: pm, state_language: StateLanguage.take)
    _(language_progress2).must_be :valid?
  end

  it 'gives monthly outcome scores accross a date range' do
    pu0 = ProgressUpdate.new progress: 1, year:2015, month: 8
    pu1 = ProgressUpdate.new progress: 2, year:2015, month: 8
    pu2 = ProgressUpdate.new progress: 3, year:2015, month: 10
    pu3 = ProgressUpdate.new progress: 1, year:2015, month: 11
    # multiple updates in one month - the last one takes precedence
    pu0.created_at = Date.new(2015,8,5)
    pu1.created_at = Date.new(2015,8,10)
    language_progress.progress_updates << [pu0, pu1, pu2, pu3]
    language_progress.progress_marker.weight = 1
    scores = language_progress.outcome_scores(Date.new(2015,7,1), Date.new(2015,12,1))
    value(scores.count).must_equal 6
    value(scores['July 2015']).must_equal 0
    value(scores['August 2015']).must_equal 2
    value(scores['September 2015']).must_equal 2
    value(scores['October 2015']).must_equal 3
    value(scores['November 2015']).must_equal 1

    # check the last of multiple updates in a month really is taking precedence
    pu0.created_at = Date.new(2015,8,10)
    pu1.created_at = Date.new(2015,8,5)
    scores = language_progress.outcome_scores(Date.new(2015,7,1), Date.new(2015,12,1))
    value(scores['August 2015']).must_equal 1

    # check progress marker weight is taken into account
    language_progress.progress_marker.weight = 2
    scores = language_progress.outcome_scores(Date.new(2015,6,1), Date.new(2015,12,1))
    value(scores['October 2015']).must_equal 6
  end

  it 'knows the score for a given month' do
    pu1.save
    pu2.save
    _(language_progress.month_score(2015, 8)).must_equal 2
    _(language_progress.month_score(2015, 10)).must_equal 3
  end

  it 'uses the latest update of multiple given in a single month' do
    pu1.created_at = Date.new(2015,8,5)
    pu1.save!
    pu2.month = 8
    pu2.created_at = Date.new(2015,8,10)
    pu2.save!
    language_progress.reload
    _(language_progress.month_score(2015, 8)).must_equal pu2.progress
    pu1.created_at = Date.new(2015,8,15)
    pu1.save!
    language_progress.reload
    _(language_progress.month_score(2015, 8)).must_equal pu1.progress

    # check progress marker weight is taken into account
    language_progress.progress_marker.weight = 2
    _(language_progress.month_score(2015, 8)).must_equal pu1.progress * 2
  end

  it 'projects the earliest month score backwards in time' do
    pu1.save
    _(language_progress.month_score(2010, 1)).must_equal pu1.progress

    # check progress marker weight is taken into account
    language_progress.progress_marker.weight = 2
    _(language_progress.month_score(2010, 1)).must_equal pu1.progress * 2

    # 0 if there's no progress updates at all
    language_progress.progress_updates.clear
    _(language_progress.month_score(2010, 1)).must_equal 0
  end

  it 'projects the earliest month score backwards in time using the last added update for multiple in earliest month' do
    pu1.month = pu2.month
    pu1.created_at = Date.new(2015,8,5)
    pu2.created_at = Date.new(2015,8,10)
    pu1.save!
    pu2.save!
    language_progress.reload
    _(language_progress.month_score(2010, 1)).must_equal pu2.progress
    pu1.created_at = Date.new(2015,8,15)
    pu1.save!
    language_progress.reload
    _(language_progress.month_score(2010, 1)).must_equal pu1.progress
  end

  it 'has a scope for having progress_updates' do
    lp_count = LanguageProgress.count
    lp_up_count = LanguageProgress.with_updates.count
    language_progress.progress_updates.clear
    language_progress.save!
    value(LanguageProgress.count).must_equal lp_count + 1
    value(LanguageProgress.with_updates.count).must_equal lp_up_count
  end

end
