#@javascript
@poltergeist
Feature: Assigning multiple states to a user

  Background:
    Given seed data is loaded into the database
    Given I login as an admin

  Scenario:
    When I visit the new user page
    Then the state selector has no states
    And there is a zone selector
    When I select the zone north_east
    Then the state selector has the states arunachal_pradesh and assam
    When I select the zone hindi_zone
    Then the state selector has the states bihar and up
    When I unselect the zone north_east
    Then the state selector does not have the states arunachal_pradesh and assam
    When I select the states bihar and up
    And I complete the user form
    And I submit the form
    Then I am on the user page
    And I see bihar and up
