@wip
Feature: User signs in
  In order to access the repository
  As a user that starts a session
  I want to log in

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged out

  Scenario: successful login
    When I visit the home page
    Then I should see the login screen
    When I fill in "Login" with "Nobody"
    And fill in "Password" with "se7en!"
    And click on "Log in"
    Then I should be within the application
    And I should see a notice "Successfully logged in as William Blake"

  Scenario: failing login
    When I visit the home page
    And I fill in "Login" with "Nobody"
    And fill in "Password" with "ei8ht?"
    And click on "Log in"
    Then I should see the login screen
    And should see an error "Invalid login or password"

  Scenario: service unavailable
    Given the authentication service is not available
    When I visit the home page
    And fill in "Login" with "Nobody"
    And fill in "Password" with "se7en"
    And click on "Log in"
    Then I should not see the application desktop
    But I should see an alert with "Service not available"
