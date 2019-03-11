# This script assumes you are starting with an empty database.
# The idea is to fill the database with nonsensical data that
# resembles the data that would exist in reality during use of the app

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
state_ids = []
zone_ids.each do |z_id|
  rand(3..9).times{ state_ids << GeoState.create(zone_id: z_id, name: state_names.shift).id }
end

# Lets create between 510 and 520 languages
language_ids = []
rand(510..520).times do
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
  #TODO: classification, ethnic groups in area, lexical similarity, believers, l2_literacy, pseudonym
  if l.save
    language_ids << l.id
  else
    @errors << l.errors.full_messages
  end
end