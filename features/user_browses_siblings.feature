@wip
Feature: User browses siblings
  In order to explore a concept level
  As a user browsing the concept map
  I want to see the siblings of a concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: offset placeholders
    Given a concept "pocket billiards" exists
    And this concept has narrower concepts "pool", "snooker", "English billiards"
    And "pool" has a narrower concept "8-ball"
    When I visit the concept details page for "snooker"
    Then I should see a concept node "snooker"
    And this concept node should be horizontally centered below "pocket billiards"
    And I should see a placeholder node representing the siblings of "snooker"
    And this placeholder should have a count of "2"
    And this placeholder should be placed on the right next to "snooker"
    And I should see a placeholder node representing the children of "snooker"
    And this placeholders should be horizontally centered below "snooker"
    When I click on "Toggle orientation"
    Then I should still see "snooker"
    And this concept node should placed on the right next to "pocket billiards"
    And I should see a placeholder node representing the siblings of "snooker"
    And this placeholder should be placed below "snooker"
    And I should see a placeholder node representing the children of "snooker"
    And this placeholders should be on the right next to "snooker"

  Scenario: expand and reorder
    Given a concept "carom billiards" exists
    And "carom billiards" has a narrower concept with English term "five pin billiards"
    And "five pin billiards" has a German term "Billiardkegeln"
    And "carom billiards" has a narrower concept with English term "straight rail billiards"
    And "straight rail billiards" has a German term "Freie Partie"
    And "carom billiards" has a narrower concept with English term "balkline billiards"
    And "balkline billiards" has a German term "Cadre-Disziplin"
    When I visit the concept details page for "five pin billiards"
    And I click the placeholder to expand the siblings of "five pin billiards"
    Then I should see "balkline billiards", "five pin billiards", "straight rail billiards" in this order
    When I select "German" as source language
    Then I should see "Billiardkegeln", "Cadre-Disziplin", "Freie Partie" in this order
