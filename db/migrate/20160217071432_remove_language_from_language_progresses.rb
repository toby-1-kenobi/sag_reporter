class RemoveLanguageFromLanguageProgresses < ActiveRecord::Migration
  def up
    change_column_null(:language_progresses, :language_id, true)
    LanguageProgress.find_each do |lp|
      language = lp.language
      # with no language we've pulled up a new LanguageProgress that we created in this migration
      if language
        geo_state = nil
        other_lps = Hash.new
        lp.progress_updates.each do |pu|
          if geo_state
            if pu.geo_state != geo_state
              if !other_lps[pu.geo_state]
                other_lps[pu.geo_state] = lp.dup
                other_lps[pu.geo_state].state_language = StateLanguage.find_by(geo_state: pu.geo_state, language: language)
                other_lps[pu.geo_state].language = nil
                other_lps[pu.geo_state].save!
                puts "created new LanguageProgress #{other_lps[pu.geo_state].id} for #{language.name} in #{pu.geo_state.name}"
              end
              pu.language_progress = other_lps[pu.geo_state]
              pu.save!
            end
          else
            geo_state = pu.geo_state
            #puts "LanguageProgress #{lp.id} is for #{language.name} in #{geo_state.name}"
            sl = StateLanguage.find_by(geo_state: geo_state, language: language)
            if sl
              lp.state_language = sl
              lp.save!
            else
              puts pu.id
              puts language
              puts geo_state
              fail "could not find StateLanguage for #{language.name} in #{geo_state.name} as required by progressUpdate #{pu.id}"
            end
          end
        end
        if !geo_state
          # this LanguageProgress has no ProgressUpdates, it is not used and can safely be deleted
          lp.destroy
        end
      end
    end
    remove_column :language_progresses, :language_id
  end

  def down
    add_reference :language_progresses, :language, index: true, foreign_key: true
    LanguageProgress.find_each do |lp|
      if existing_lp = LanguageProgress.find_by(progress_marker: lp.progress_marker, language_id: lp.state_language.language_id)
        lp.progress_updates.each do |pu|
          pu.language_progress = existing_lp
          pu.save!
        end
        lp.reload
        puts "destroying LanguageProgress #{lp.id} in favour of #{existing_lp.id}"
        lp.destroy
      else
        lp.language_id = lp.state_language.language_id
        lp.save!
      end
    end
  end

end
