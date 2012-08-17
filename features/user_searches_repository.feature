@wip
Feature: User searches repository
  In order to get a list of relevant concepts
  As a user that searches for a specific information
  I want to enter a query string and trigger a search

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: trigger search
    When I enter "poet" in the search field
    And I click the search button
    Then I should see "/concepts/search?search%5Bquery%5D=poet" in the navigation bar
    And I should see a progress indicator

  Scenario: service unavailable
    Given the repository is not available
    When I enter "poet" in the search field
    And I click the search button
    Then I should see an error "Service is currently unavailable"

  Scenario: unauthorized
    Given my auth token timed out
    When I enter "poet" in the search field
    And I click the search button
    Then I should see a prompt for the password
    When I enter "ei8ht?" for password
    And click on "Proceed"
    Then I should see a prompt for the password
    When I enter "se7en!" for password
    And click on "Proceed"
    Then I should see a progress indicator
