Feature: assigning geo-states to languages
  
  Background:
    Given a language
    Given some geo-states
    Given I login as admin

  Scenario: I can assign geo-states to a language
    When I visit the language edit page
    And I choose geo states from the list
    And I submit the form
    Then I am on the language page
    And I see the geo states listed
