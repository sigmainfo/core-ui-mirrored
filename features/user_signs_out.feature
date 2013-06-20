Feature: user signs out
  In order to secure the access to the repository
  As a user closing a session
  I want to log off the repository

  Scenario: log out
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    When I click on "Log out"
    Then I should see the login form
    But I should not see the footer
