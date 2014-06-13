Feature: visitor browses repository as guest
  In order to get an immediate hands-on experience browsing real data
  As a visitor evaluating our service
  I want to log into a public repository as guest

  Background:
    Given a public repository "Coreon Demo" exists
    And I am not logged in

  Scenario: click to login
    When I visit the welcome page
    Then I see a link "Log in as guest"
    When I click "Log in as guest"
    Then I see "Logged in as guest"
    And I am on the repository root page of "Coreon Demo"

  @wip
  Scenario: follow link
    Given a concept "Example" exists
    When I follow a public link to this concept
    Then I see "Logged in as guest"
    And I see the concept details page for "Example"
