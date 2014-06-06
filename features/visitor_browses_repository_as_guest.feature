Feature: visitor browses repository as guest
  In order to get an immediate hands-on experience browsing real data
  As a visitor evaluating our service
  I want to log into a public repository as guest

  Background:
    Given a public repository "Coreon Demo" exists

  @wip
  Scenario: click to login
    Given I am not logged in
    When I visit the welcome page
    Then I see a link "Login as guest"
    When I click "Login as guest"
    Then I see "Logged in as guest"
    And I am on the repository root page of "Coreon Demo"
