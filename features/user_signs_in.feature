Feature: user signs in
  In order to access the repository
  As a user that starts a session
  I want to log in

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged out

  Scenario: successful login
    When I visit the home page
    Then I should see the login screen
    When I fill in "Email" with "nobody@blake.com"
    And fill in "Password" with "se7en!"
    And click on "Log in"
    Then I should be within the application
    And I should see a notice "Successfully logged in as William Blake"

  Scenario: failing login
    When I visit the home page
    And I fill in "Email" with "nobody@blake.com"
    And fill in "Password" with "ei8ht?"
    And click on "Log in"
    Then I should see the login screen
    And should see an error "Invalid email or password"

  Scenario: service unavailable
    Given I visit the home page
    And the authentication service is not available
    When I fill in "Email" with "nobody@blake.com"
    And fill in "Password" with "se7en!"
    And click on "Log in"
    Then I should see the login screen
    And I should see an error "Service is currently unavailable"
