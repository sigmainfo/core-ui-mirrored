@wip
Feature: User signs out
  In order to secure the access to the repository
  As a user closing a session
  I want to log off the repository

  Scenario: log out
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in
    When I click to open the footer
    And cklick on "Log out"
    Then I should not be within the application
    But should see the login form
    And should see a notice "Successfully logged out"
