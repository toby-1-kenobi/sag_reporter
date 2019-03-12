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

# Start with 5 zones
zone_ids = []
%w(North South East West Central).each{ |name| zone_ids << Zone.create(name: name).id }

# Each zone has between 3 and 9 states
# here's 45 randomly generated names to choose from
state_names = %w(Icelake Fayelf Deepland Clearhollow Meadowbush Prydell Corvale Westercrystal Eriton Eastfort Violetdell Stoneden Wildefay Aldfog Brightpine Newwell Stonehill Aelfield Summermoor Goldspring Starrymarsh Mallowsnow Wayholt Lorwynne Newbutter Rayvale Vertland Prywynne Swynbeach Crystaldell Stoneshore Glassden Merrowville Redice Courtmere Havenhollow Winterfield Wheatlake Faydeer Lightpond Whitehill Ashmarsh Dracmeadow Byhedge Aldapple).shuffle
state_ids_by_zone = {}
zone_ids.each do |z_id|
  state_ids_by_zone[z_id] = []
  rand(3..9).times{ state_ids_by_zone[z_id] << GeoState.create(zone_id: z_id, name: state_names.shift).id }
end

# set up an interface language "English"
ui_lang_id = Language.create(name: 'English', locale_tag: 'en').id

# now create around 680 users
user_count = short_seed ? 60 : rand(660..700)
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
  combo = case rand * 1000
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
    @errors << u.errors.full_messages
  end
end
User.update_all(registration_status: User.registration_statuses['approved'])

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
  l.iso = Faker::Lorem.unique.characters(3) if rand < 0.92
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
    @errors << l.errors.full_messages
  end
end

# State Languages
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
  sl = StateLanguage.new(language_id: l_id, geo_state_id: states.shift, primary: true)
  sl.project = true if rand < 0.37
  sl.save
  while states.any?
    sl = StateLanguage.new(language_id: l_id, geo_state_id: states.shift, primary: false)
    sl.project = true if rand < 0.16
    sl.save
  end
end

# Finish Line Markers
flm_ids = []
(1..rand(9..13)).each do |n|
  flm_ids << FinishLineMarker.create(
      name: "#{Faker::Verb.past_participle} #{Faker::Dessert.variety}",
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

language_names.keys.each do |l_id|
  flp_years = (2019..(this_year + 16)).to_a
  # 70% of languages have planning values for finish line progress
  if rand < 0.7
    year = flp_years.shift
    previous = {}
    flm_ids.each do |flm_id|
      # probabilities of each status in first planning year
      status = case rand * 3818
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
    # as the panning years progress leave behind 20% of languages each time
    while flp_years.any? and rand < 0.8
      year = flp_years.shift
      flm_ids.each do |flm_id|
        # probabilities than one status will convert to the next in any given year
        status = case previous[flm_id]
                 when "no_need"
                   rand < 0.004 ? "survey_needed" : "no_need"
                 when "not_accessible"
                   rand < 0.01 ? "survey_needed" : "not_accessible"
                 when "survey_needed"
                   rand < 0.02 ? "in_progress" : "survey_needed"
                 when "confirmed_need"
                   rand < 0.1 ? "in_progress" : "confirmed_need"
                 when "in_progress"
                   rand < 0.2 ? "completed" : "in_progress"
                 when "outside_india_in_progress"
                   rand < 0.2 ? "completed" : "outside_india_in_progress"
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

if @errors.any?
  puts 'errors encountered creating sandbox data:'
  @errors.each{ |e| puts e }
else
  puts 'no errors'
end
ending_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "#{Utils.seconds_to_string((ending_time - starting_time).floor)} elapsed during seeding"