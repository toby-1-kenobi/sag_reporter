@javascript
Feature: Reporting on an event

  Background:
    Given seed data is loaded into the database
    Given I am an admin
    Given I login

  Scenario: I can find the event reporting page and see its components
    When I visit the home page
    Then I see a link to the new event page
    When I follow the link to the new event page
    Then I am on the new event page
    And I see a text field for the event label
    And I see a date field for the event
    And I see a textarea for the event location
    And I see a number field for the number of participants
    And I see a text field for a participant name
    And I see a multi-select for minority languages
    And I see a selectbox for event purpose
    And I see yes/no radio buttons for things said at the event
    And I see a textarea for event content
    When I put text in the participant name field
    Then I see another participant name field
    When I click a yes radio button
    Then I see a textarea for the thing said at the event
    When I click a no radio button
    Then I cannot see a textarea for the thing said at the event
    When I put text in the textarea for the thing said at the event
    Then I see another textarea for the thing said at the event
