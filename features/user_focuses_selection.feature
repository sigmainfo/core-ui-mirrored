@wip
Feature: User focuses selection
  In order to focus on the selection at hand
  As a user browsing the concept map
  I want to see curently selected concepts in the center of the concept map

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: navigate concept map
    Given I have selected a repository "Billiards"
    And a concept "pocket billiards" exists
    And this concept has narrower concepts "pool", "snooker", "English billiards"
    And "pool" has narrower concepts "8-ball", "nine ball"
    And a concept "carom billiards" exists
    And this concept has a narrower concept "five pin billiards"
    When I visit the repository root page
    Then I should see the repository node being vertically centered
    And it should be slightly above the center
    When I click "Toggle orientation"
    Then I should see the repository node being horizontally centered
    And it should be slightly left of the center
    When I click "Toggle orientation"
    And I click the placeholder node
    Then the repository node should have moved up by a level
    When I click on pocket billiards
    Then pocket billiards should be horizontally and vertically centered
    When I search for "billiard"
    Then "pocket billiards" and "English billiards" should be visible
