@wip
Feature: People

  Background:
    Given seed data is loaded into the database
    Given I am an admin
    Given I have contacts
    Given there are people who are not my contacts
    Given I login

  Scenario: I can find a list of my contacts and a list of all people
    When I visit the home page
    And I follow the link to my contacts
    Then I see the names of only my contacts
    When I click on show all people
    Then I see the names of more people

  Scenario: I can add a new contact
    When I visit the contacts page
    And I click on Add Contact
    And I fill in the person form
    Then I am on a page showing my new contact
    When I click on my contacts
    Then I see the name of the new contact