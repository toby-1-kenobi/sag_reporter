Feature: View Reports

  Impact reports and other types of reports can be viewed and filtered.
  Different sets of reports and different available filters will show
  in different contexts.

  Background:
    Given seed data is loaded into the database
    Given I login

  Scenario: a report can be edited and archived by its reporter.
    Given I have a report
    When I go to the report page for my report
    Then I see an "edit" button on a report
    And I see an "archive" button on a report

  Scenario: a report cannot be edited or archived by a normal user that didn't create it.
    Given Andrew Admin has a report
    And I am in the state for that
    When I go to the report page for Andrew Admin's report
    Then I do not see an "edit" button on a report
    And I do not see an "archive" button on a report

  Scenario: any report can be edited or archived by an admin user.
    Given Emma Pleb has a report
    And I am in the state for that
    And I am an admin user
    When I go to the report page for Emma Pleb's report
    Then I see an "edit" button on a report
    And I see an "archive" button on a report