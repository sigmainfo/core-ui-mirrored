Feature: user browses child nodes
  In order to explore specifics of a concept
  As a user browsing the concept map
  I want to expand the child nodes of a concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: expand child nodes
    Given I have selected a repository "Billiards"
    And a concept "pocket billiards" exists
    And this concept has narrower concepts "pool", "snooker", "English billiards"
    And "pool" has narrower concepts "8-ball", "nine ball"
    And a concept "carom billiards" exists
    And this concept has a narrower concept "five pin billiards"
    When I visit the repository root page
    Then I should see the repository node within the concept map
    And I should see a placeholder node deriving from it
    And this placeholder should have an object count of "2"
    When I click this placeholder
    Then I should see two concept nodes "pocket billiards" and "carom billiards"
    But I should not see this placeholder anymore
    And both concepts should be connected to the repository node
    And I should see a placeholder deriving from each of them
    And I should see object count "1" for placeholder connected to "carom billiards"
    And I should see object count "3" for placeholder connected to "pocket billiards"
    When I click the placeholder connected to "pocket billiards"
    Then I should see three concept nodes "pool", "snooker", "English billiards"
    And these should be connected to "pocket billiards"
    And I should see a placeholder deriving from "pool" and "carom billiards"
    But I should not see the placeholder connected to "pocket billiards" anymore
    And I should see object count "2" for placeholder connected to "pool"
