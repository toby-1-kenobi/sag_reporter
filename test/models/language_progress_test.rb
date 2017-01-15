require "test_helper"

describe LanguageProgress do
  let(:language_progress) { LanguageProgress.new progress_marker: pm, state_language: sl }
  let(:pm) { ProgressMarker.new name: 'test pm', description: 'test pm', topic: topics(:language_development)}
  let(:sl) { StateLanguage.new }

  it "must be valid" do
    value(language_progress).must_be :valid?
  end

  it "wont be valid without a progress marker" do
    language_progress.progress_marker = nil
    language_progress.valid?
    _(language_progress.errors[:progress_marker]).must_be :any?
  end

  it "wont be valid without a state_language" do
    language_progress.state_language = nil
    language_progress.valid?
    _(language_progress.errors[:state_language]).must_be :any?
  end

  it "must have a unique progress marker within each state_language" do
    language_progress.save
    language_progress2 = LanguageProgress.new progress_marker: pm, state_language: sl
    language_progress2.valid?
    _(language_progress2.errors[:progress_marker]).must_be :any?
  end

  it "may have non-unique progress marker with different state_language" do
    language_progress.save
    language_progress2 = LanguageProgress.new(progress_marker: pm, state_language: StateLanguage.take)
    _(language_progress2).must_be :valid?
  end

  it "gives monthly outcome scores accross a date range" do
    pu1 = ProgressUpdate.new progress: 2, year:2015, month: 8
    pu2 = ProgressUpdate.new progress: 3, year:2015, month: 10
    pu3 = ProgressUpdate.new progress: 1, year:2015, month: 11
    language_progress.progress_updates << [pu1, pu2, pu3]
    language_progress.progress_marker.weight = 1
    scores = language_progress.outcome_scores(Date.new(2015,7,1), Date.new(2015,12,1))
    value(scores.count).must_equal 6
    value(scores["July 2015"]).must_equal 0
    value(scores["August 2015"]).must_equal 2
    value(scores["September 2015"]).must_equal 2
    value(scores["October 2015"]).must_equal 3
    value(scores["November 2015"]).must_equal 1
    language_progress.progress_marker.weight = 2
    scores = language_progress.outcome_scores(Date.new(2015,6,1), Date.new(2015,12,1))
    value(scores["August 2015"]).must_equal 4
  end

  it "has a scope for having progress_updates" do
    lp_count = LanguageProgress.count
    lp_up_count = LanguageProgress.with_updates.count
    language_progress.progress_updates.clear
    language_progress.save!
    value(LanguageProgress.count).must_equal lp_count + 1
    value(LanguageProgress.with_updates.count).must_equal lp_up_count
  end

end
