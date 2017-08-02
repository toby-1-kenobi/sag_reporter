Feature: Zone dashboard

  The Zone dashboard aggregates data for any particular zone.
  It also allows navigation to any state or language that falls
  within that zone.

  Background:
    Given seed data is loaded into the database
    Given I login

  Scenario: I can see all states and languages when I am a national user
    When I am a national user
    And I go to the zone page for my zone
    Then all states of the zone are listed
    And all languages of the zone are listed

  Scenario: I can see only my states and languages when I am not a national user
    When I am not a national user
    And I go to the zone page for my zone
    Then only my states of the zone are listed
    And only my languages of the zone are listed