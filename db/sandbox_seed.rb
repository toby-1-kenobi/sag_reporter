# This script assumes you are starting with an empty database.
# The idea is to fill the database with nonsensical data that
# resembles the data that would exist in reality during use of the app

class Utils

  # human readable time froms seconds
  def self.seconds_to_string(s)

    # d = days, h = hours, m = minutes, s = seconds
    m = (s / 60).floor
    s = s % 60
    h = (m / 60).floor
    m = m % 60
    d = (h / 24).floor
    h = h % 24

    output = "#{s} second#{Utils.pluralize(s)}" if (s > 0)
    output = "#{m} minute#{Utils.pluralize(m)}, #{s} second#{Utils.pluralize(s)}" if (m > 0)
    output = "#{h} hour#{Utils.pluralize(h)}, #{m} minute#{Utils.pluralize(m)}, #{s} second#{Utils.pluralize(s)}" if (h > 0)
    output = "#{d} day#{Utils.pluralize(d)}, #{h} hour#{Utils.pluralize(h)}, #{m} minute#{Utils.pluralize(m)}, #{s} second#{Utils.pluralize(s)}" if (d > 0)

    return output
  end

  def self.pluralize number
    return "s" unless number == 1
    return ""
  end

end

# set short_seed to true to reduce the number of records seeded
short_seed = Rails.env.development?

starting_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
this_year = Time.now.year
@errors = []
@info = []

# don't keep a record of changes while inserting seed data
PaperTrail.enabled = false

# generate a unique name
@used_names = Set.new
@vowels = %w(a e i o u)
@consonants = %w(q w r t y p s d f g h j k l z x c v b n m)
def unique_name
  name = ''
  rand(1..3).times{ name += @consonants.sample + @vowels.sample }
  name += @consonants.sample if rand < 0.5
  name = @used_names.include?(name) ? unique_name : name
  @used_names << name
  name
end

# generate a unique iso code
@used_isos = Set.new
def unique_iso
  iso = []
  3.times{ iso << ('a'..'z').to_a.sample }
  iso = iso.join
  iso = @used_isos.include?(iso) ? unique_iso : iso
  @used_isos << iso
  iso
end

# Start with 5 zones
zone_ids = []
%w(North South East West Central).each{ |name| zone_ids << Zone.create(name: name).id }

# Each zone has between 3 and 9 states
# here's 45 randomly generated names to choose from (with some LoTR mixed in)
state_names = %w(Icelake Fayelf Deepland Clearhollow Meadowbush Prydell Mordor Westercrystal Gondor Eastfort Rohan Stoneden Wildefay Aldfog Brightpine Newwell Stonehill Aelfield Summermoor Goldspring Starrymarsh Mallowsnow Wayholt Lorwynne Newbutter Arnor Haradwaith Prywynne Swynbeach Crystaldell Stoneshore Glassden Merrowville Redice Courtmere Havenhollow Winterfield Wheatlake Shire Eriador Whitehill Ashmarsh Dracmeadow Byhedge Aldapple).shuffle
state_ids_by_zone = {}
zone_ids.each do |z_id|
  state_ids_by_zone[z_id] = []
  rand(3..9).times{ state_ids_by_zone[z_id] << GeoState.create(zone_id: z_id, name: state_names.shift).id }
end
@info << "#{GeoState.count} states"

# set up an interface language "English"
ui_lang_id = Language.create(name: 'English', locale_tag: 'en').id

# now create around 680 users
user_count = short_seed ? 50 : rand(660..700)
user_ids = []
user_count.times do
  password = Faker::Internet.password
  u = User.new(
      name: Faker::Name.unique.name,
      password: password,
      password_confirmation: password,
      password_changed: Time.now,
      interface_language_id: ui_lang_id,
      user_last_login_dt: Date.today - rand(0..500).days,
      # registration_status unapproved means it wont try to send out confirmation emails
      # all get changed to approved after all users created
      registration_status: 'unapproved'
  )
  zone = zone_ids.sample
  states = Set.new
  if rand < 0.2
    # some users are in more than one state
    states.merge state_ids_by_zone[zone].sample(rand(2..5))
    if rand < 0.1
      # some are even in more than one zone
      zone = zone_ids.sample
      states.merge state_ids_by_zone[zone].sample(rand(1..3))
    end
  else
    states << state_ids_by_zone[zone].sample
  end
  puts states
  u.geo_state_ids = states.to_a
  u.phone = Faker::Number.number(10) if rand < 0.85
  # only use safe fake emails, so we're not accidentally sending real people emails.
  u.email = Faker::Internet.safe_email(u.name.underscore + rand(99).to_s) if u.phone.blank? || rand < 0.96
  u.email_confirmed = true if u.email.present? and rand < 0.6
  # realistic probability of each combo of booleans occurring is maintained
  # admin, national, trusted, lci_board, lci_agency, forward_planning_curator, zone_admin
  combo = case rand 1000
          when (0..382)
            7.times.map{ false }
          when (383..643)
            [false, false, true] + 4.times.map{ false }
          when (644..829)
            [false, true, true] + 4.times.map{ false }
          when (830..955)
            [false, true] + 5.times.map{ false }
          when (956..971)
            [false, true, true, true, false, false, false]
          when (972..985)
            [false, true, true, true, true, false, false]
          else
            7.times.map{ true }
          end
  u.admin = combo.shift
  u.national = combo.shift
  u.trusted = combo.shift
  u.lci_board_member = combo.shift
  u.lci_agency_leader = combo.shift
  u.forward_planning_curator = combo.shift
  u.zone_admin = combo.shift
  u.role_description = Faker::Job.title if rand < 0.3
  if u.save
    user_ids << u.id
  else
    @errors << "user #{u.errors.full_messages}"
  end
end
User.update_all(registration_status: User.registration_statuses['approved'])
@info << "#{User.count} users"

# at least one user curating in each state
GeoState.find_each do |gs|
  u_id = gs.user_ids.sample
  Curating.create(user_id: u_id, geo_state: gs)
  if rand < 0.5
    states = state_ids_by_zone[gs.zone_id].sample(rand(1..8))
    states.delete(gs.id)
    states.each{ |state| Curating.create(user_id: u_id, geo_state_id: state) }
  end
end

# Language families
family_ids = []
%w(Elvish Dwarfish Orkish Mannish Entish).each do |family|
  family_ids << LanguageFamily.create(name: family).id
end

# create between 510 and 520 languages
language_count = short_seed ? 50 : rand(510..520)
language_names = {}
language_count.times do
  l = Language.new(name: unique_name)
  # 5% chance the language name has a second word
  l.name += " #{unique_name}" if rand < 0.05
  # 3% chance it has a comma
  l.name += ", #{unique_name}" if rand < 0.03
  # 2% chance it has braces
  l.name += " (#{unique_name})" if rand < 0.02
  # 1% chance it has a slash
  l.name += " / #{unique_name}" if rand < 0.01
  # 92% chance it has an iso code
  l.iso = unique_iso if rand < 0.92
  # 30% have a description
  l.description = Faker::Lorem.paragraph(2, true, 4) if rand < 0.5
  # 90% have a location
  l.location = Faker::Lorem.paragraph(1, true, 3) if rand < 0.9
  # and so on
  l.number_of_translations = rand(0..2) if rand < 0.5
  l.info = Faker::Lorem.paragraph(1, true, 2) if rand < 0.6
  l.translation_info = Faker::Lorem.paragraph(1, true, 6) if rand < 0.8
  l.population_concentration = Faker::Lorem.sentence(3, true, 6) if rand < 0.1
  vs_lo = rand(1..40) * 5
  vs_hi = (vs_lo + 20) * rand(1..3)
  vs_hi += 5 if vs_hi % 10 == 5
  village_size = [
      "#{vs_lo}-#{vs_hi} families per village",
      "#{vs_lo} to #{vs_hi} houses",
      "Each group has an average of #{vs_lo}-#{vs_hi} households",
      "#{vs_lo}-#{vs_hi} households per village",
      "#{vs_lo}-#{vs_hi} families",
      "Very small, no more than #{vs_lo} houses per village",
      "average less than #{vs_hi} people per village",
      "They settle in colonies of approx. #{(vs_lo + vs_hi)/2} houses",
      "#{vs_lo}-#{vs_hi} houses in a settlement",
      "small villages",
      "About #{(vs_lo + vs_hi)/2} families per village",
      "Varies greatly",
      "#{vs_lo}-#{vs_hi} per village"
  ]
  l.village_size = village_size.sample if rand < 0.2
  l.mixed_marriages = Faker::Lorem.sentence(3, true, 6) if rand < 0.1
  l.clans = Faker::Lorem.words(rand(3..8), true).join(', ') if rand < 0.08
  l.castes = Faker::Lorem.words(rand(3..8), true).join(', ') if rand < 0.08
  l.location_access = Faker::Lorem.paragraph(1, true, 2) if rand < 0.1
  l.travel = Faker::Lorem.paragraph(1, true, 1) if rand < 0.1
  religions = %w(Christian Hindu Traditional\ religion Buddhist Muslim).shuffle
  percents = [rand(80..99)]
  while percents.length < religions.length and percents.sum < 100 do
    percents << rand(1..10)
  end
  diff = 100 - percents.sum
  percents[-1] += diff
  l.religion = percents.map{ |p| "#{religions.shift} #{p}%"}.join(', ') if rand < 0.7
  l.local_fellowship = true if rand < 0.1
  lit_bel = rand(1..9) * 10
  lit_bel_text = [
      "Perhaps #{lit_bel}%, in the state language",
      "Higher than the average literacy rate",
      "among believers so far #{lit_bel}%, the women can't read",
      "Approx. #{lit_bel}% (rough estimate)",
      "#{lit_bel}%+ for those under 40. #{lit_bel/2}% for those 40 or older",
      "Most have good opportunity for education from mission schools",
      "yes but less",
      "Many",
      "Educational achievement higher among Christians than non-Christians",
      "#{lit_bel}%",
      "very few"
  ].sample
  l.literate_believers = lit_bel_text if rand < 0.1
  l.related_languages = Faker::Lorem.paragraph(1, true, 4) if rand < 0.6
  l.attitude = Faker::Lorem.paragraph(1, true, 4) if rand < 0.3
  if rand < 0.3
    earliest = rand((this_year - 150)..(this_year - 10))
    l.portions_first_published = earliest
    l.portions_last_published = rand((earliest + 8)..this_year) if rand < 0.8
    if (this_year - earliest) > 20
      earliest += rand(8..20)
      l.nt_first_published = earliest
      l.nt_last_published = rand((earliest + 5)..this_year) if rand < 0.8 and earliest + 5 <= this_year
      if (this_year - earliest) > 50
        earliest = rand((earliest + 20)..this_year)
        l.bible_first_published = earliest
        l.bible_last_published = rand((earliest + 5)..this_year) if rand < 0.6 and earliest + 5 < this_year
      end
    end
  end
  l.selections_published = (this_year - rand(10..40)).to_s if rand < 0.05
  l.tr_committee_established = true if rand < 0.05
  mt_lit = []
  5.times{ mt_lit << 'Below 1%'}
  2.times{ mt_lit << '1% to 5%'}
  mt_lit += ['5% to 10%', '10% to 30%', '60%', '80%']
  2.times{ mt_lit << Faker::Lorem.sentence(3, true, 6) }
  l.mt_literacy = mt_lit.sample if rand < 0.1
  l.script = %w(Roman, Elvish, Mordorian, Runes).sample if rand < 0.5
  l.attitude_to_lang_dev = Faker::Lorem.paragraph(3, true, 3) if rand < 0.1
  l.mt_literacy_programs = ['Y', "Y, since #{this_year - rand(10..40)}", Faker::Lorem.sentence(5, true, 5)].sample if rand < 0.1
  l.poetry_print = true if rand < 0.05
  l.oral_traditions_print = true if rand < 0.02
  l.sensitivity = 0 if rand < 0.05
  l.champion_id = user_ids.sample if rand < 0.3
  l.champion_prompted = Date.today - rand(10..80).days
  l.family_id = family_ids.sample if rand < 0.9
  l.genetic_classification = ([l.family.name] + Faker::Lorem.words(rand(1..5), true)).join(', ') if l.family_id.present? and rand < 0.9
  #TODO: ethnic groups in area, lexical similarity, believers, l2_literacy, pseudonym
  if l.save
    language_names[l.id] = l.name
  else
    @errors << "language #{l.errors.full_messages}"
  end
end
@info << "#{Language.count} languages"

# dialects
language_names.keys.each do |l_id|
  if rand < 0.3
    rand(1..7).times{ Dialect.create(language_id: l_id, name: unique_name) }
  end
end

# 5 outcome areas
topic_ids = []
colours = %w(amber yellow pink lime green).shuffle
(1..5).each do |n|
  topic_ids << Topic.create(
      name: "#{Faker::Food.vegetables} #{Faker::Verb.ing_form}",
      description: Faker::Lorem.sentence,
      number: n,
      colour: colours.shift
  ).id
end

# Progress Markers
# number of pms of each weight per outcome area
pm_ids = []
pm_pattern = { 1 => 3, 2 => 3, 3 => 2 }
pm_number = 0
topic_ids.each do |t_id|
  pm_pattern.each do |weight, count|
    count.times do
      pm_number += 1
      pm_ids << ProgressMarker.create(
          name: Faker::Company.bs,
          topic_id: t_id,
          weight: weight,
          number: pm_number
      ).id
    end
  end
end

# State Languages
state_language_ids_by_state = {}
language_ids_by_state = {}
lp_ids_by_state_language = {}
language_names.keys.each do |l_id|
  zone = zone_ids.sample
  states = Set.new
  if rand < 0.3
    # 30% of languages are in more than one state
    states.merge state_ids_by_zone[zone].sample(rand(2..4))
    if rand < 0.4
      # some are even in more than one zone
      zone = zone_ids.sample
      states.merge state_ids_by_zone[zone].sample(rand(1..3))
    end
  else
    states << state_ids_by_zone[zone].sample
  end
  states = states.to_a
  state = states.shift
  sl = StateLanguage.new(language_id: l_id, geo_state_id: state, primary: true)
  sl.project = true if rand < 0.37
  sl.save
  state_language_ids_by_state[state] ||= []
  state_language_ids_by_state[state] << sl.id
  language_ids_by_state[state] ||= []
  language_ids_by_state[state] << l_id
  if sl.project?
    lp_ids_by_state_language[sl] = []
    pm_ids.each{ |pm_id| lp_ids_by_state_language[sl] << LanguageProgress.create(progress_marker_id: pm_id, state_language_id: sl.id).id }
  end
  while states.any?
    state = states.shift
    sl = StateLanguage.new(language_id: l_id, geo_state_id: state, primary: false)
    sl.project = true if rand < 0.16
    sl.save
    state_language_ids_by_state[state] ||= []
    state_language_ids_by_state[state] << sl.id
    language_ids_by_state[state] ||= []
    language_ids_by_state[state] << l_id
    if sl.project?
      lp_ids_by_state_language[sl] = []
      pm_ids.each{ |pm_id| lp_ids_by_state_language[sl] << LanguageProgress.create(progress_marker_id: pm_id, state_language_id: sl.id).id }
    end
  end
end
@info << "#{StateLanguage.count} state-languages"

# add a language to any state that doesn't have one
state_ids_by_zone.values.each do |states|
  states.each do |state|
    unless state_language_ids_by_state[state]
      l_id = language_names.keys.sample
      sl_id = StateLanguage.create(
          language_id: l_id,
          geo_state_id: state,
          primary: false
      ).id
      state_language_ids_by_state[state] = [sl_id]
      language_ids_by_state[state] = [l_id]
    end
  end
end

# Finish Line Markers
flm_ids = []
(1..rand(9..13)).each do |n|
  flm_ids << FinishLineMarker.create(
      name: "#{Faker::Verb.past_participle.titlecase} #{Faker::Dessert.variety}",
      description: Faker::Lorem.question,
      number: n
  ).id
end

# Finish Line Progresses
def flm_current_from_plan(l_id, flm_id, status)
  current_status = case status
                   when "no_need"
                     rand < 0.06 ? "survey_needed" : "no_need"
                   when "not_accessible"
                     rand < 0.15 ? "survey_needed" : "not_accessible"
                   when "survey_needed"
                     rand < 0.02 ? "in_progress" : "survey_needed"
                   when "in_progress"
                     rand < 0.27 ? "survey_needed" : "in_progress"
                   when "completed"
                     rand < 0.13 ? "in_progress" : "completed"
                   when "further_work_in_progress"
                     rand < 0.1 ? "in_progress" : "further_work_in_progress"
                   else
                     status
                   end
  FinishLineProgress.create(
      language_id: l_id,
      finish_line_marker_id: flm_id,
      status: current_status,
      year: nil
  )
end

# finish line progress for each language
language_names.keys.each do |l_id|
  flp_years = (2019..(this_year + 10)).to_a
  # 70% of languages have planning values for finish line progress
  if rand < 0.7
    year = flp_years.shift
    previous = {}
    flm_ids.each do |flm_id|
      # probabilities of each status in first planning year
      status = case rand 3818
               when (0..454)
                 "no_need"
               when (455..580)
                 "not_accessible"
               when (581..2426)
                 "survey_needed"
               when (2427..2546)
                 "confirmed_need"
               when (2547..3028)
                 "in_progress"
               when (3029..3031)
                 "outside_india_in_progress"
               when (3031..3638)
                 "completed"
               when (3639..3693)
                 "further_needs_expressed"
               else
                 "further_work_in_progress"
               end
      FinishLineProgress.create(
          language_id: l_id,
          finish_line_marker_id: flm_id,
          status: status,
          year: year
      )
      previous[flm_id] = status
      # current year corresponds to this year of planning
      flm_current_from_plan(l_id, flm_id, status) if year == this_year
    end
    while flp_years.any?
      year = flp_years.shift
      flm_ids.each do |flm_id|
        # probabilities than one status will convert to the next in any given year
        status = case previous[flm_id]
                 when "no_need"
                   rand < 0.004 ? "survey_needed" : "no_need"
                 when "not_accessible"
                   rand < 0.01 ? "survey_needed" : "not_accessible"
                 when "survey_needed"
                   rand < 0.3 ? "in_progress" : "survey_needed"
                 when "confirmed_need"
                   rand < 0.5 ? "in_progress" : "confirmed_need"
                 when "in_progress"
                   rand < 0.4 ? "completed" : "in_progress"
                 when "outside_india_in_progress"
                   rand < 0.3 ? "completed" : "outside_india_in_progress"
                 when "completed"
                   rand < 0.004 ? "further_work_in_progress" : "completed"
                 when "further_needs_expressed"
                   rand < 0.1 ? "further_work_in_progress" : "further_needs_expressed"
                 else
                   rand < 0.1 ? "completed" : "further_work_in_progress"
                 end
        FinishLineProgress.create(
            language_id: l_id,
            finish_line_marker_id: flm_id,
            status: status,
            year: year
        )
        previous[flm_id] = status
        # current year corresponds to this year of planning
        flm_current_from_plan(l_id, flm_id, status) if year == this_year
      end
    end
  else
    # languages that have no planning finish line progress
    # still have current status
    flm_ids.each do |flm_id|
      status = case rand * 1617
               when (0..82)
                 'no_need'
               when (83..1093)
                 'survey_needed'
               when (1094..1108)
                 'confirmed_need'
               when (1109..1224)
                 'in_progress'
               when (1225..1609)
                 'completed'
               when (1610..1613)
                 'further_needs_expressed'
               else
                 'further_work_in_progress'
               end

      FinishLineProgress.create(
          language_id: l_id,
          finish_line_marker_id: flm_id,
          status: status,
          year: nil
      )
    end
  end
end
@info << "#{FinishLineProgress.count} Finish Line progress records"

# Streams
stream_ids = []
rand(8..10).times do
  name = "#{Faker::Verb.ing_form} #{Faker::Food.fruits}".titlecase
  m = Ministry.create(topic_id: topic_ids.sample, code: ('A'..'Z').to_a.sample(2).join)
  m.name_en = name
  m.short_form_en = name.gsub(/[^A-Z]/, '') # get acronym of name
  stream_ids << m.id
end

# Measurables
stream_ids.each do |s_id|
  (1..rand(4..12)).each do |n|
    d = Deliverable.create(
        ministry_id: s_id,
        number: n,
        calculation_method: rand < 0.2 ? 0 : 1,
        reporter: rand < 0.3 ? 0 : 1,
        funder_interest: rand < 0.5 ? false : true
    )
    d.short_form_en = Faker::Company.bs
    d.result_form_en = Faker::Lorem.question
    d.plan_form_en = Faker::Lorem.question
  end
end

# Organisations
org_count = short_seed ? 140 : rand(1400..1450)
org_ids = []
org_count.times do
  org_name = Faker::Company.name
  org_ids << Organisation.create(
      name: org_name,
      abbreviation: org_name.gsub(/[^A-Z]/, ''),
      church: rand < 0.33 ? false : true,
  ).id
end
@info << "#{Organisation.count} organisations"

# connecting organisations to languages
language_names.keys.each do |l_id|
  if rand < 0.5
    orgs = org_ids.sample(3)
    OrganisationTranslation.create(language_id: l_id, organisation_id: orgs.shift)
    if rand < 0.35
      OrganisationTranslation.create(language_id: l_id, organisation_id: orgs.shift)
      OrganisationTranslation.create(language_id: l_id, organisation_id: orgs.shift) if rand < 0.17
    end
    orgs = org_ids.sample(rand(1..7))
    orgs.each{ |o| OrganisationEngagement.create(language_id: l_id, organisation_id: o) }
  end
end

# Projects
sub_project_ids_by_project = {}
rand(25..30).times do
  p = Project.create(name: Faker::Lorem.sentence(2))
  sub_project_ids_by_project[p.id] = []
  if rand < 0.5
    rand(2..4).times do
      sub_project_ids_by_project[p.id] << SubProject.create(
          project: p,
          name: "#{Faker::Color.color_name} #{Faker::Food.ingredient}"
      ).id
    end
  end
end
@info << "#{Project.count} projects"
project_ids = sub_project_ids_by_project.keys

project_rel_ids = {}
project_ids.each do |p_id|
  project_rel_ids[p_id] = {}

  # connect projects with languages
  states = state_ids_by_zone.values.sample.shuffle
  state_languages = state_language_ids_by_state[states.shift].sample(rand(1..14))
  state_languages.each{ |sl| ProjectLanguage.create(project_id: p_id, state_language_id: sl) }
  project_rel_ids[p_id][:state_languages] = state_languages
  # 20% of projects are in more than one state
  if rand < 0.2
    state_count = [rand(1..3), states.length].min
    (1..state_count).each do |n|
      state_languages = state_language_ids_by_state[states.shift].sample(rand(1..14/n))
      state_languages.each{ |sl| ProjectLanguage.create(project_id: p_id, state_language_id: sl) }
      project_rel_ids[p_id][:state_languages] += state_languages
    end
  end

  # connect projects with supervisors
  supervisors = user_ids.sample(rand(3..12))
  supervisors.each do |sup_id|
    role = case rand 243
           when (0..106)
             0
           when (107..136)
             1
           else
             2
           end
    ProjectSupervisor.create(project_id: p_id, user_id: sup_id, role: role)
  end

  # connect projects with streams
  project_rel_ids[p_id][:streams] = stream_ids.sample(rand(1..stream_ids.length))
  project_rel_ids[p_id][:streams].each do |s_id|
    ProjectStream.create(project_id: p_id, ministry_id: s_id, supervisor_id: rand < 0.3 ? nil : user_ids.sample)
  end

  # connect with facilitators
  sub_proj = sub_project_ids_by_project[p_id]
  project_rel_ids[p_id][:streams].each do |s_id|
    project_rel_ids[p_id][:state_languages].each do |sl_id|
      fac_count = case rand 1026
                  when (0..493)
                    0
                  when (494..963)
                    1
                  when (964..1016)
                    2
                  else
                    3
                  end
      user_ids.sample(fac_count).each do |u_id|
        LanguageStream.create(
            project_id: p_id,
            ministry_id: s_id,
            state_language_id: sl_id,
            facilitator_id: u_id,
            sub_project_id: sub_proj.any? ? sub_proj.sample : nil
        )
      end
    end
  end

end

proj_sl = ProjectLanguage.pluck(:state_language_id).uniq

# Church Teams
church_team_count = short_seed ? 100 : rand(1900..2100)
team_ids = []
church_team_count.times do
  ct_id = ChurchTeam.create(
      leader: Faker::Name.name,
      organisation_id: org_ids.sample,
      state_language_id: proj_sl.sample
  ).id
  stream_count = case rand 2017
                 when (0..9)
                   1
                 when (10..508)
                   2
                 when (509..837)
                   3
                 when (838..1119)
                   4
                 when (1120..1351)
                   5
                 when (1352..1591)
                   6
                 else
                   7
                 end
  stream_ids.sample(stream_count).each do |s_id|
    ChurchMinistry.create(church_team_id: ct_id, ministry_id: s_id)
  end
  team_ids << ct_id
end
@info << "#{ChurchTeam.count} church teams"

# Reports
report_count = short_seed ? 300 : rand(11000..12000)
report_count.times do
  state = state_ids_by_zone[zone_ids.sample].sample
  ir = ImpactReport.new(shareable: rand < 0.06 ? true : false)
  r = Report.new(
      content: Faker::Lorem.paragraph(rand(1..10)),
      impact_report: ir,
      reporter_id: user_ids.sample,
      geo_state_id: state,
      project_id: rand < 0.01 ? project_ids.sample : nil,
      church_team_id: rand < 0.08 ? team_ids.sample : nil,
      significant: rand < 0.22 ? true : false,
      report_date: Date.today - rand(1100).days,
      archived: rand < 0.01 ? 1 : 0
  )
  if r.save
    language_count = rand < 0.1 ? 2 : 1
    r.language_ids = language_ids_by_state[state].sample(language_count)
  else
    @errors << "report #{r.errors.full_messages}"
  end
end
@info << "#{Report.count} reports"

cat_ids = []
[
    "Discipleship resources (books, audio)",
    "Educational resources (books, charts)",
    "Songs (audio)",
    "Academic resources about this language",
    "Cultural resources (books, audio)"
].each_with_index do |category_name, n|
  pc = ProductCategory.create(number: n)
  pc.name.en = category_name
  cat_ids << pc.id
end

# tools
language_names.keys.each do |l_id|
  if rand < 0.7
    rand(1..6).times do
      t = Tool.create(
          language_id: l_id,
          creator_id: user_ids.sample,
          description: Faker::Lorem.sentence,
          finish_line_marker_id: flm_ids.sample,
          url: "https://example.com"
      )
      t.product_category_ids = cat_ids.sample(rand(1..2))
    end
  end
end

# progress updates
tracking_langs = StateLanguage.in_project.pluck(:id)
# we'll need an upward trend so use different lambdas for getting the random value
trends = [
    lambda{ |n| rand(rand(rand(n..3)+1)+1) },
    lambda{ |n| rand(rand(n..3)+1) },
    lambda{ |n| rand(n..3) }
]
# update on a quarterly basis across 3 years
((this_year - 3)..(this_year - 1)).each do |year|
  trend = trends.shift
  [3, 6, 9, 12].each_with_index do |month, i|
    # only quarter of the languages included on any given update
    tracking_langs.sample(tracking_langs.length / 4).each do |sl_id|
      lp_ids_by_state_language[sl_id].each do |lp_id|
        ProgressUpdate.create(
            year: year,
            month: month,
            language_progress_id: lp_id,
            user_id: user_ids.sample,
            progress: trend.call(i)
        )
      end
    end
  end
end

# Books of the Bible in order with number of verses for each chapter
bible = {
    "Gen"=>["Genesis", 31, 25, 24, 26, 32, 22, 24, 22, 29, 32, 32, 20, 18, 24, 21, 16, 27, 33, 38, 18, 34, 24, 20, 67, 34, 35, 46, 22, 35, 43, 55, 32, 20, 31, 29, 43, 36, 30, 23, 23, 57, 38, 34, 34, 28, 34, 31, 22, 33, 26],
    "Ex"=>["Exodus", 22, 25, 22, 31, 23, 30, 25, 32, 35, 29, 10, 51, 22, 31, 27, 36, 16, 27, 25, 26, 36, 31, 33, 18, 40, 37, 21, 43, 46, 38, 18, 35, 23, 35, 35, 38, 29, 31, 43, 38],
    "Lev"=>["Leviticus", 17, 16, 17, 35, 19, 30, 38, 36, 24, 20, 47, 8, 59, 57, 33, 34, 16, 30, 37, 27, 24, 33, 44, 23, 55, 46, 34],
    "Num"=>["Numbers", 54, 34, 51, 49, 31, 27, 89, 26, 23, 36, 35, 16, 33, 45, 41, 50, 13, 32, 22, 29, 35, 41, 30, 25, 18, 65, 23, 31, 40, 16, 54, 42, 56, 29, 34, 13],
    "Deut"=>["Deuteronomy", 46, 37, 29, 49, 33, 25, 26, 20, 29, 22, 32, 32, 18, 29, 23, 22, 20, 22, 21, 20, 23, 30, 25, 22, 19, 19, 26, 68, 29, 20, 30, 52, 29, 12],
    "Josh"=>["Joshua", 18, 24, 17, 24, 15, 27, 26, 35, 27, 43, 23, 24, 33, 15, 63, 10, 18, 28, 51, 9, 45, 34, 16, 33],
    "Judg"=>["Judges", 36, 23, 31, 24, 31, 40, 25, 35, 57, 18, 40, 15, 25, 20, 20, 31, 13, 31, 30, 48, 25],
    "Ruth"=>["Ruth", 22, 23, 18, 22],
    "1 Sam"=>["1 Samuel", 28, 36, 21, 22, 12, 21, 17, 22, 27, 27, 15, 25, 23, 52, 35, 23, 58, 30, 24, 42, 15, 23, 29, 22, 44, 25, 12, 25, 11, 31, 13],
    "2 Sam"=>["2 Samuel", 27, 32, 39, 12, 25, 23, 29, 18, 13, 19, 27, 31, 39, 33, 37, 23, 29, 33, 43, 26, 22, 51, 39, 25],
    "1 Kings"=>["1 Kings", 53, 46, 28, 34, 18, 38, 51, 66, 28, 29, 43, 33, 34, 31, 34, 34, 24, 46, 21, 43, 29, 53],
    "2 Kings"=>["2 Kings", 18, 25, 27, 44, 27, 33, 20, 29, 37, 36, 21, 21, 25, 29, 38, 20, 41, 37, 37, 21, 26, 20, 37, 20, 30],
    "1 Chron"=>["1 Chronicles", 54, 55, 24, 43, 26, 81, 40, 40, 44, 14, 47, 40, 14, 17, 29, 43, 27, 17, 19, 8, 30, 19, 32, 31, 31, 32, 34, 21, 30],
    "2 Chron"=>["2 Chronicles", 17, 18, 17, 22, 14, 42, 22, 18, 31, 19, 23, 16, 22, 15, 19, 14, 19, 34, 11, 37, 20, 12, 21, 27, 28, 23, 9, 27, 36, 27, 21, 33, 25, 33, 27, 23],
    "Ezra"=>["Ezra", 11, 70, 13, 24, 17, 22, 28, 36, 15, 44],
    "Neh"=>["Nehemiah", 11, 20, 32, 23, 19, 19, 73, 18, 38, 39, 36, 47, 31],
    "Est"=>["Esther", 22, 23, 15, 17, 14, 14, 10, 17, 32, 3],
    "Job"=>["Job", 22, 13, 26, 21, 27, 30, 21, 22, 35, 22, 20, 25, 28, 22, 35, 22, 16, 21, 29, 29, 34, 30, 17, 25, 6, 14, 23, 28, 25, 31, 40, 22, 33, 37, 16, 33, 24, 41, 30, 24, 34, 17],
    "Ps"=>["Psalms", 6, 12, 8, 8, 12, 10, 17, 9, 20, 18, 7, 8, 6, 7, 5, 11, 15, 50, 14, 9, 13, 31, 6, 10, 22, 12, 14, 9, 11, 12, 24, 11, 22, 22, 28, 12, 40, 22, 13, 17, 13, 11, 5, 26, 17, 11, 9, 14, 20, 23, 19, 9, 6, 7, 23, 13, 11, 11, 17, 12, 8, 12, 11, 10, 13, 20, 7, 35, 36, 5, 24, 20, 28, 23, 10, 12, 20, 72, 13, 19, 16, 8, 18, 12, 13, 17, 7, 18, 52, 17, 16, 15, 5, 23, 11, 13, 12, 9, 9, 5, 8, 28, 22, 35, 45, 48, 43, 13, 31, 7, 10, 10, 9, 8, 18, 19, 2, 29, 176, 7, 8, 9, 4, 8, 5, 6, 5, 6, 8, 8, 3, 18, 3, 3, 21, 26, 9, 8, 24, 13, 10, 7, 12, 15, 21, 10, 20, 14, 9, 6],
    "Prov"=>["Proverbs", 33, 22, 35, 27, 23, 35, 27, 36, 18, 32, 31, 28, 25, 35, 33, 33, 28, 24, 29, 30, 31, 29, 35, 34, 28, 28, 27, 28, 27, 33, 31],
    "Eccles"=>["Ecclesiastes", 18, 26, 22, 16, 20, 12, 29, 17, 18, 20, 10, 14],
    "Song"=>["Song of Solomon", 17, 17, 11, 16, 16, 13, 13, 14],
    "Isa"=>["Isaiah", 31, 22, 26, 6, 30, 13, 25, 22, 21, 34, 16, 6, 22, 32, 9, 14, 14, 7, 25, 6, 17, 25, 18, 23, 12, 21, 13, 29, 24, 33, 9, 20, 24, 17, 10, 22, 38, 22, 8, 31, 29, 25, 28, 28, 25, 13, 15, 22, 26, 11, 23, 15, 12, 17, 13, 12, 21, 14, 21, 22, 11, 12, 19, 12, 25, 24],
    "Jer"=>["Jeremiah", 19, 37, 25, 31, 31, 30, 34, 22, 26, 25, 23, 17, 27, 22, 21, 21, 27, 23, 15, 18, 14, 30, 40, 10, 38, 24, 22, 17, 32, 24, 40, 44, 26, 22, 19, 32, 21, 28, 18, 16, 18, 22, 13, 30, 5, 28, 7, 47, 39, 46, 64, 34],
    "Lam"=>["Lamentations", 22, 22, 66, 22, 22],
    "Ezek"=>["Ezekiel", 28, 10, 27, 17, 17, 14, 27, 18, 11, 22, 25, 28, 23, 23, 8, 63, 24, 32, 14, 49, 32, 31, 49, 27, 17, 21, 36, 26, 21, 26, 18, 32, 33, 31, 15, 38, 28, 23, 29, 49, 26, 20, 27, 31, 25, 24, 23, 35],
    "Dan"=>["Daniel", 21, 49, 30, 37, 31, 28, 28, 27, 27, 21, 45, 13],
    "Hos"=>["Hosea", 11, 23, 5, 19, 15, 11, 16, 14, 17, 15, 12, 14, 16, 9],
    "Joel"=>["Joel", 20, 32, 21],
    "Amos"=>["Amos", 15, 16, 15, 13, 27, 14, 17, 14, 15],
    "Obad"=>["Obadiah", 21],
    "Jonah"=>["Jonah", 17, 10, 10, 11],
    "Mic"=>["Micah", 16, 13, 12, 13, 15, 16, 20],
    "Nah"=>["Nahum", 15, 13, 19],
    "Hab"=>["Habakkuk", 17, 20, 19],
    "Zeph"=>["Zephaniah", 18, 15, 20],
    "Hag"=>["Haggai", 15, 23],
    "Zech"=>["Zechariah", 21, 13, 10, 14, 11, 15, 14, 23, 17, 12, 17, 14, 9, 21],
    "Mal"=>["Malachi", 14, 17, 18, 6],
    "Matt"=>["Matthew", 25, 23, 17, 25, 48, 34, 29, 34, 38, 42, 30, 50, 58, 36, 39, 28, 27, 35, 30, 34, 46, 46, 39, 51, 46, 75, 66, 20],
    "Mark"=>["Mark", 45, 28, 35, 41, 43, 56, 37, 38, 50, 52, 33, 44, 37, 72, 47, 20],
    "Luke"=>["Luke", 80, 52, 38, 44, 39, 49, 50, 56, 62, 42, 54, 59, 35, 35, 32, 31, 37, 43, 48, 47, 38, 71, 56, 53],
    "John"=>["John", 51, 25, 36, 54, 47, 71, 53, 59, 41, 42, 57, 50, 38, 31, 27, 33, 26, 40, 42, 31, 25],
    "Acts"=>["Acts", 26, 47, 26, 37, 42, 15, 60, 40, 43, 48, 30, 25, 52, 28, 41, 40, 34, 28, 41, 38, 40, 30, 35, 27, 27, 32, 44, 31],
    "Rom"=>["Romans", 32, 29, 31, 25, 21, 23, 25, 39, 33, 21, 36, 21, 14, 23, 33, 27],
    "1 Cor"=>["1 Corinthians", 31, 16, 23, 21, 13, 20, 40, 13, 27, 33, 34, 31, 13, 40, 58, 24],
    "2 Cor"=>["2 Corinthians", 24, 17, 18, 18, 21, 18, 16, 24, 15, 18, 33, 21, 14],
    "Gal"=>["Galatians", 24, 21, 29, 31, 26, 18],
    "Eph"=>["Ephesians", 23, 22, 21, 32, 33, 24],
    "Phil"=>["Philippians", 30, 30, 21, 23],
    "Col"=>["Colossians", 29, 23, 25, 18],
    "1 Thess"=>["1 Thessalonians", 10, 20, 13, 18, 28],
    "2 Thess"=>["2 Thessalonians", 12, 17, 18],
    "1 Tim"=>["1 Timothy", 20, 15, 16, 16, 25, 21],
    "2 Tim"=>["2 Timothy", 18, 26, 17, 22],
    "Titus"=>["Titus", 16, 15, 15],
    "Philem"=>["Philemon", 25],
    "Heb"=>["Hebrews", 14, 18, 19, 16, 14, 20, 28, 13, 28, 39, 40, 29, 25],
    "James"=>["James", 27, 26, 18, 17, 20],
    "1 Pet"=>["1 Peter", 25, 25, 22, 19, 14],
    "2 Pet"=>["2 Peter", 21, 22, 18],
    "1 John"=>["1 John", 10, 29, 24, 21, 21],
    "2 John"=>["2 John", 13],
    "3 John"=>["3 John", 15],
    "Jude"=>["Jude", 25],
    "Rev"=>["Revelation", 20, 29, 22, 11, 14, 17, 17, 13, 21, 11, 19, 17, 18, 20, 8, 21, 18, 24, 21, 15, 27, 21]
}
n = 1
bible.each do |abr, x|
  b = Book.create(name: x.shift, abbreviation: abr, number: n, nt: n > 39)
  x.each_with_index{ |c, i| Chapter.create(book: b, verses: c, number: i + 1) }
  n += 1
end

PaperTrail.enabled = true

if @errors.any?
  puts 'errors encountered creating sandbox data:'
  @errors.each{ |e| puts e }
else
  puts 'no errors'
end
@info.each{ |i| puts i }
ending_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "#{Utils.seconds_to_string((ending_time - starting_time).floor)} elapsed during seeding"