#@javascript
#@poltergeist

Feature: Users with multiple states

  Some users need to be in more than one geo_state.
  In this case when the user is entering state-sensitive data
  They need to have a way to select which state it's for
  and when they 

  Background:
    Given seed data is loaded into the database
    Given I login as an admin

  @javascript @wip
  Scenario: Assigning multiple states to a user
    When I visit the new user page
    Then the state selector has no states
    When I select the zone "North East"
    Then the state selector has the states arunachal_pradesh and assam
    When I select the zone hindi_zone
    Then the state selector has the states bihar and up
    When I unselect the zone "North East"
    Then the state selector does not have the states arunachal_pradesh and assam
    When I select the states bihar and up
    And I complete the user form
    And I submit the form
    Then I am on the user page
    And I see bihar and up

  Scenario: Seeing state selector for data entry
    Given I am in 2 states
    When I visit the "new_report" page
    Then I see the state dropdown with 2 states

