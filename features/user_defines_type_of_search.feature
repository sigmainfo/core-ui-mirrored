Feature: user defines type of search
  In order to search within the definition or for term values only
  As a user doing a search for concepts
  I want to select a search type

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  @firefox
  Scenario: set search target
    Then I should see the hint "Search all" in the search input
    When I click on the triangle within the search input
    Then I should see a dropdown with "All", "Concepts by Definition", and "Concepts by Terms"
    And "All" should be selected
    When I click on "Concepts by Terms"
    Then I should not see the dropdown
    But I should see the hint "Search concepts by terms" in the search input
    When I click on the triangle within the search input
    Then I should see a dropdown with "All", "Concepts by Definition", and "Concepts by Terms"
    And "Concepts by Terms" should be selected
    When I click outside the dropdown
    Then I should not see the dropdown
    But I should see the hint "Search concepts by terms" in the search input
    When I enter "poet" in the search field
    And I click the search button
    Then I should be on the search concepts page with target "terms" and query "poet"
