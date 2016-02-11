require "test_helper"

describe ProgressUpdate do

  let(:progress_update) { ProgressUpdate.new geo_state: geo_states(:nb),
      progress: ProgressMarker.spread_text.keys.first,
      year: 2015, month: 1,
      user: users(:andrew),
      language_progress: language_progress
    }
    
  let(:language_progress) {LanguageProgress.new language: languages(:toto),
      progress_marker: progress_markers(:disease_prevented)
    }

  it "must be valid" do
    value(progress_update).must_be :valid?
  end
end
