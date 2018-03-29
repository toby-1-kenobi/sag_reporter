require 'test_helper'

describe ProgressUpdate do

  let(:progress_update) { ProgressUpdate.new progress: ProgressMarker.spread_text.keys.first,
      year: 2015, month: 1,
      user: users(:andrew),
      language_progress: language_progress
    }
    
  let(:language_progress) {LanguageProgress.new state_language: state_languages(:nb_toto),
      progress_marker: progress_markers(:disease_prevented)
    }

  it 'must be valid' do
    puts progress_update.errors.full_messages unless progress_update.valid?
    value(progress_update).must_be :valid?
  end

  it 'is sortable on progress_date, then creation date' do
    pu1 = ProgressUpdate.new year: 2015, month: 5
    pu2 = ProgressUpdate.new year: 2015, month: 8, created_at: 1.minute.ago
    pu3 = ProgressUpdate.new year: 2015, month: 8, created_at: Time.now
    pu4 = ProgressUpdate.new year: 2016, month: 1
    _([pu4, pu3, pu2, pu1].sort!).must_equal [pu1, pu2, pu3, pu4]
  end

end
