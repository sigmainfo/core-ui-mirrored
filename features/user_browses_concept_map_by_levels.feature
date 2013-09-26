@wip
Feature: user browses concept map by levels
  In order to understand the position of a concept within the overall hierarchy
  As a user exploringing the concept map
  I want to see concepts from the same level side by side

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: browse concept hierarchy
    Given I am browsing a repository called "Games"
    And a top level concept "billiards" exists
    And "billiards" has a narrower concept "equipment"
    And "equipment" has narrower concepts "ball", "cue", "table" 
    And "billiards" has a narrower concept "types"
    And "types" has a narrower concept "pool"
    And "pool" has narrower concepts "8-ball", "nine ball"
    When I do a search for "ball"
    Then I should see hits "ball", "8-ball", "nine ball" in the concept map
    And I should see a repository root node "Games"
    And I should see "billiards" at level 1
    And I should see "equipment", "types" on level 2
    And I should see "ball", "pool" at level 3
    And I should see "8-ball", "nine ball" at level 4
    And "billiards", "equipment", "types", "pool" should be more prominent than "cue", "table"
