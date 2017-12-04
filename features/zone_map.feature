
Feature: Clickable zone map

  There is a map of India showing strategic zones.
  If you are a member of any particular zone you can
  click on it and it will take you to the zone dashboard.
  National users can click on any zone.

  Background:
    Given zones data is loaded into the database
    Given I login

  Scenario: I can click on any zone when I am a national user
    When I am a national user
    And I go to the zones page
    Then I can click on any zone in the map
    And I see a link to the nation page

  Scenario: I can only click on my zones when I am not a national user
    When I am not a national user
    And I go to the zones page
    Then I can click on only my zones in the map
    And I do not see a link to the nation page