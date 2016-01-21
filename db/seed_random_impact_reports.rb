total_amount = 100

puts "Adding #{total_amount} random impact reports to the database."

users = User.all.select{ |u| u.can_create_report? }

if users.empty?
  fail "no users can create a report!"
end

year = 2015
month_possibilities = [9, 10, 11, 12]

geo_state = GeoState.find_by_name "(northern) West Bengal"
geo_state ||= GeoState.take

unless geo_state
  fail "you need to have States in the db first!"
end

languages = geo_state.languages

progress_markers = ProgressMarker.all

(0..total_amount).each do |index|
  report = ImpactReport.create({
    reporter: users.sample,
    content: Faker::Lorem.paragraph,
    state: :active,
    geo_state: geo_state,
    report_date: Date.new(year, month_possibilities.sample)
    })
  begin
    report.languages << languages.take((rand 3)+1)
  rescue ActiveRecord::RecordNotUnique
    print '^l'
  end
  begin
    report.progress_markers << progress_markers.take((rand 4)+1)
  rescue ActiveRecord::RecordNotUnique
    print '^p'
  end
  if report.persisted?
    print '.'
  else
    print '*'
  end
end