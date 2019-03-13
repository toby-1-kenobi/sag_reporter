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

# State Languages
state_language_ids_by_state = {}
language_ids_by_state = {}
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
  while states.any?
    state = states.shift
    sl = StateLanguage.new(language_id: l_id, geo_state_id: state, primary: false)
    sl.project = true if rand < 0.16
    sl.save
    state_language_ids_by_state[state] ||= []
    state_language_ids_by_state[state] << sl.id
    language_ids_by_state[state] ||= []
    language_ids_by_state[state] << l_id
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
  flp_years = (2019..(this_year + 16)).to_a
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
pm_pattern = { 1 => 3, 2 => 3, 3 => 2 }
pm_number = 0
topic_ids.each do |t_id|
  pm_pattern.each do |weight, count|
    count.times do
      pm_number += 1
      ProgressMarker.create(
          name: Faker::Company.bs,
          topic_id: t_id,
          weight: weight,
          number: pm_number
      )
    end
  end
end

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
      report_date: Date.today - rand(1100).days
  )
  if r.save
    language_count = rand < 0.1 ? 2 : 1
    r.language_ids = language_ids_by_state[state].sample(language_count)
  else
    @errors << "report #{r.errors.full_messages}"
  end
end
@info << "#{Report.count} reports"

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