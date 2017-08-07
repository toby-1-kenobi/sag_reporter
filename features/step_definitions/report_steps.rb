Given(/^I have a report$/) do
  impact_report = ImpactReport.create
  state = @me.geo_states.take
  @my_report = Report.create(
            content: 'my report content',
            report_date: Date.today,
            reporter: @me,
            impact_report: impact_report,
            geo_state: state
  )
  _(@my_report).must_be :persisted?
  @my_report.languages << state.languages.take
end

Given(/^([A-Z][a-z]* ?[A-Z]?[a-z]*) has a report$/) do |user_name|
  impact_report = ImpactReport.create
  user = User.find_by_name user_name
  state = user.geo_states.take
  @object = Report.create(
      content: 'my report content',
      report_date: Date.today,
      reporter: user,
      impact_report: impact_report,
      geo_state: state
  )
  _(@object).must_be :persisted?
  @object.languages << state.languages.take
  puts "created report (#{@object.id}) for #{user.name} in #{state.name}"
end