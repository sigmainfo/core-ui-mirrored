Feature: User browses all terms of source language
  In order to explore the lexical scope of the selected source language
  As a user browsing the term sphere
  I want to scroll through an alphabetic list of all existing terms

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And the languages "English", "German", and "French" are available
    And I am logged in

  @wip
  Scenario: browse source language
    Given a concept with English term "ball" exists
    And this concept has German terms "Ball", "Kugel"
    And the following English terms exist: "chalk", "cue", "billiards"
    And the following English terms exist: "vegetarian meal", "mushroom"
    And the following German terms exist: "Kreide", "Queue", "Billiard"
    And the following German terms exist: "Asiatisches Essen", "Pilz"
    When I visit the repository root page
    And I select "English" as source language
    Then I should see "ball", "billiards", "chalk", "cue" inside the Term List
    And and these should be followed by "mushroom", "vegetarian meal"
    When I select "German" as source language
    Then I should see "Asiatisches Essen", "Ball" inside the Term List
    And and these should be followed by "Billiard", "Kreide", "Kugel", "Pilz"
    And and these should be followed by "Queue"
    When I click on "Ball"
    Then I should see "Ball", "Kugel" inside the Term List
    When I click on "Toggle scope"
    Then I should see "Asiatisches Essen", "Ball" inside the Term List
    And and these should be followed by "Billiard", "Kreide", "Kugel", "Pilz"
    And and these should be followed by "Queue"
    And "Ball", "Kugel" should be marked as being currently selected
