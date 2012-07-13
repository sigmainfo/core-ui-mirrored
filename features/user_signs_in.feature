@wip
Feature: User logs into the repository
  In order to access the repository
  As a user that starts a session
  I want to log in

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged out

  Scenario: successful login
    When I visit the home page
    Then I should see the login form
    When I fill in "Login" with "Nobody"
    And fill in "Password" with "se7en"
    And click on "Log in"
    Then I should see the application desktop
    And I should see a notice "Logged in successfully as Wiliam Blake"

  Scenario: failing login
    When I visit the home page
    And fill in "Login" with "Nobody"
    And fill in "Password" with "ei8ht"
    And click on "Log in"
    Then I should not see the application desktop
    But I should see the login form
    And should see an alert with "Invalid login or password"

  Scenario: service unavailable
    Given the authentication service is not available
    When I visit the home page
    And fill in "Login" with "Nobody"
    And fill in "Password" with "se7en"
    And click on "Log in"
    Then I should not see the application desktop
    But I should see an alert with "Service not available"
