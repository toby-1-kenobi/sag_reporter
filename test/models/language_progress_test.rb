require "test_helper"

describe LanguageProgress do
  let(:language_progress) { LanguageProgress.new progress_marker: pm, state_language: sl }
  let(:pm) { ProgressMarker.new }
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

end
