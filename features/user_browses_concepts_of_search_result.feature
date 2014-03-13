Feature: User browses concepts of search result
  In order to identify most relevant concept hits
  As a user that has searched the repository
  I want to see a list of concept results featuring basic information on each


  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: concept result list
    Given a concept with label "ball" exists
    And this concept has broader concepts "equipment" and "billiards"
    And a concept with label "ballistics" exists
    And it is defined as "Mechanics that describe behavior of projectiles"
    And a concept with label "balloon" exists
    And a concept with label "game play" exists
    When I enter "ball" in the search field
    And I click the search button
    Then I should see a listing of search results
    And it should display labels for "ball", "ballistics", "balloon"
    And I should be on the search results page for query "ball"
    And each of them should have a section "BROADER"
    And it should contain "equipment" and "billiards" for "ball"
    And it should be empty for "ballistics" and "balloon"
    And "ballistics" should have a section "DEFINITION"
    And it should contain "Mechanics that describe behavior of projectiles"
    But "DEFINITION" should not be displayed for "ball" and "balloon"
    When I click on "ballistics"
    Then I should see the details for concept "ballistics"
    And I should be on the concept details page for "ballistics"

  @focus
  Scenario: displayed languages
    Given a concept with label "ball" exists
    And this concept has an English term "billiard ball"
    And this concept has German terms "Billiardkugel", "Kugel"
    And a concept with label "ballistics" exists
    And this concept has a German term "Ballistik"
    And a concept with label "balloon" exists
    When I visit the repository root page
    And I enter "ball" in the search field
    And I click the search button
    Then I should see "ball", "ballistics", and "balloon" as search results
    When I select "None" as source language
    And I select "None" as target language
    Then I should see language "EN" inside each of them
    And it should contain "billiard ball" for "ball"
    And it should be empty for "ballistics" and "balloon"
    When I select "German" as source language
    Then I should not see language "EN" inside any of them
    But I should see language "DE" inside each of them
    And it should contain "Billiardkugel, Kugel" for "ball"
    And it should contain "Ballistik" for "ballistics"
    And it should be empty for "balloon"
    When I select "English" as target language
    Then I should see languages "DE", "EN" inside each of them

  Scenario: no search results
    Given a concept with label "ball" exists
    When I enter "gun" in the search field
    And I click the search button
    Then I should see an empty listing of search results
    And it should contain a message: 'No concepts found for "gun"'
