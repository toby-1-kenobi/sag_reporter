require 'test_helper'

describe Language do

  let(:language) { Language.new name: 'Test language', lwc: false}
  let(:state_based_user) { FactoryBot.build(:user) }
  let(:language_prompt_due) { Language.new name: 'prompt due',
                                           updated_at: 31.days.ago,
                                           champion: state_based_user,
                                           champion_prompted: 50.days.ago }
  let(:language_prompt_nearly_due) { Language.new name: 'prompt nearly due',
                                                  updated_at: 26.days.ago,
                                                  champion: state_based_user,
                                                  champion_prompted: 50.days.ago }
  let(:language_prompt_due_later) { Language.new name: 'prompt due later',
                                                 updated_at: 24.days.ago,
                                                 champion: state_based_user,
                                                 champion_prompted: 50.days.ago }
  let(:language_prompt_overdue) { Language.new name: 'prompt overdue',
                                               updated_at: 41.days.ago,
                                               champion: state_based_user,
                                               champion_prompted: 50.days.ago }
  let(:assam) { FactoryBot.build(:geo_state, name: 'Assam') }
  let(:bihar) { FactoryBot.build(:geo_state, name: 'bihar') }
  let(:national_user) { FactoryBot.build(:user, national: true) }

  it 'must be valid' do
    value(language).must_be :valid?
  end

  it 'wont be valid with blank locale tag' do
    language.locale_tag = ''
    _(language).wont_be :valid?
  end

  it 'returns its states ids' do
  	language.geo_states << assam
  	language.geo_states << bihar
  	assam.stub(:id, 8) do
  	  bihar.stub(:id, 13) do
  	    value(language.geo_state_ids_str).must_equal '8,13'
  	  end
  	end
  end

  it 'downcases iso' do
    language.iso = 'ABc'
    language.valid?
    _(language.iso).must_equal 'abc'
  end

  it 'sets blank iso to nil' do
    language.iso = ''
    language.valid?
    assert_nil language.iso
  end

  it 'wont be valid with duplicate iso' do
    language.iso = 'abc'
    language2 = language.dup
    language.save
    _(language2).wont_be :valid?
    _(language2.errors[:iso]).must_be :any?
  end

  it 'wont limit scope for national users' do
    _(national_user).must_be :national?
    _(Language.user_limited(national_user).count).must_equal Language.all.count
  end

  it 'will limit scope for state based users' do
    _(state_based_user).wont_be :national?
    #count the languages the user has access to
    language_count = 0
    state_based_user.geo_states.each do |state|
      language_count += state.languages.count
    end
    _(language_count).wont_equal Language.all.count
    _(Language.user_limited(state_based_user).count).must_equal language_count
  end

  it 'has modification date as latest change when there are no edits' do
    _(language.last_changed.to_a).must_equal language.updated_at.to_a
  end

  it 'has latest edit date as latest change if more recent than modification date' do
    language.save
    edit = Edit.create(
            user: state_based_user,
            model_klass_name: 'Language',
            record_id: language.id,
            attribute_name: 'iso',
            old_value: '',
            new_value: 'abc',
            status: 1, # pending approval
            created_at: language.updated_at - 1.day
    )
    _(language.last_changed.to_a).must_equal language.updated_at.to_a
    edit.created_at = language.updated_at + 1.day
    edit.save
    _(language.last_changed.to_a).must_equal edit.created_at.to_a
  end

  it 'must prompt champions when there have been no edits for a while' do
    language_prompt_due.save
    mail = mock()
    mail.stubs(:deliver_now).returns(true)
    UserMailer.expects(:prompt_champion).with do |user, languages|
      _(user.id).must_equal language_prompt_due.champion_id
      _(languages.first.first.id).must_equal language_prompt_due.id
    end.once.returns(mail)
    Language.prompt_champions
  end

  it 'wont prompt champions if they have been recently prompted' do
    UserMailer.expects(:prompt_champion).never
    language_prompt_due.champion_prompted = 10.days.ago
    language_prompt_due.save
    Language.prompt_champions
  end

  it 'wont prompt champions when there have been edits in the last month' do
    UserMailer.expects(:prompt_champion).never
    language_prompt_nearly_due.save
    Language.prompt_champions
  end

  it 'wont prompt champions when there are pending edits in the last month' do
    UserMailer.expects(:prompt_champion).never
    language_prompt_due.save
    Edit.create(
        user: state_based_user,
        model_klass_name: 'Language',
        record_id: language_prompt_due.id,
        attribute_name: 'iso',
        old_value: '',
        new_value: 'abc',
        status: 1, # pending approval
        created_at: 29.days.ago
    )
    Language.prompt_champions
  end

  it 'must prompt champions for nearly due languages when the same champion has a due language' do
    language_prompt_due.save
    language_prompt_nearly_due.save
    mail = mock()
    mail.stubs(:deliver_now).returns(true)
    UserMailer.expects(:prompt_champion).with do |user, languages|
      _(user.id).must_equal language_prompt_due.champion_id
      lang_ids = [languages.first.first.id, languages.second.first.id]
      _(lang_ids).must_include language_prompt_due.id
      _(lang_ids).must_include language_prompt_nearly_due.id
    end.once.returns(mail)
    Language.prompt_champions
  end

  it 'wont prompt a champion for due languages if theres also one due later' do
    UserMailer.expects(:prompt_champion).never
    language_prompt_due.save
    language_prompt_due_later.save
    Language.prompt_champions
  end

  it 'must prompt a champion for an overdue language even if there is also one due later' do
    language_prompt_overdue.save
    language_prompt_due_later.save
    language_prompt_due.save
    language_prompt_nearly_due.save
    mail = mock()
    mail.stubs(:deliver_now).returns(true)
    UserMailer.expects(:prompt_champion).with do |user, languages|
      _(user.id).must_equal language_prompt_due.champion_id
      lang_ids = [languages.first.first.id, languages.second.first.id, languages.third.first.id]
      _(lang_ids).must_include language_prompt_overdue.id
      _(lang_ids).must_include language_prompt_due.id
      _(lang_ids).must_include language_prompt_nearly_due.id
    end.once.returns(mail)
    Language.prompt_champions
  end

  it 'must prompt a new champion for a language even if it was recently updated' do
    language_prompt_due_later.champion_prompted = nil
    language_prompt_due_later.save
    mail = mock()
    mail.stubs(:deliver_now).returns(true)
    UserMailer.expects(:prompt_champion).with do |user, languages|
      _(user.id).must_equal language_prompt_due_later.champion_id
      _(languages.first.first.id).must_equal language_prompt_due_later.id
    end.once.returns(mail)
    Language.prompt_champions
  end

  it 'returns nil for best_current_pop if it has no population objects' do
    _(language.best_current_pop).must_be_nil
  end

  it 'gives the population object as best current if theres only one' do
    pop = Population.new(amount: 5000)
    language.populations << pop
    language.save
    _(language.best_current_pop).must_equal pop
  end

  it 'gives the most recent population as best current' do
    language.populations << Population.new(amount: 500)
    pop = Population.new(amount: 1000, year: 2010)
    language.populations << pop
    language.populations << Population.new(amount: 3000, year: 1950)
    language.save
    _(language.best_current_pop).must_equal pop
  end

  it 'gives the most recently added population as best current if years are equal' do
    language.populations << Population.new(amount: 500, created_at: 1.day.ago)
    pop = Population.new(amount: 1000, created_at: 1.minute.ago)
    language.populations << pop
    language.save
    _(language.best_current_pop).must_equal pop
  end

end
