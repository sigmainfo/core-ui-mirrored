Feature: user selects repository
  In order to access data from different repositories
  As a user browsing concepts and terms
  I want to switch between repositories

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: multiple repositories
    Given I have access to the repositories "Wild West" and "Branch of Service"
    When I visit the application root
    Then I should see the repository "Wild West" within the filters bar
    And I should be on the root page of "Wild West"
    When I click the toggle of the repository selector
    Then I should see a dropdown with "Wild West" and "Branch of Service"
    And I should see "Wild West" being the currently selected repository
    When I click on "Branch of Service"
    Then I should see the repository "Branch of Service" within the filters bar
    And I should be on the root page of "Branch of Service"
    When I click the toggle of the repository selector
    Then I should see "Branch of Service" being the currently selected repository
    When I press the Escape key
    Then I should not see the dropdown
    And I should be on the root page of "Branch of Service"

  Scenario: single repository
    Given I have access to a single repository "Gunnery"
    When I visit the application root
    Then I should see the repository "Gunnery" within the filters bar
    And I should not see a repository selector toggle
