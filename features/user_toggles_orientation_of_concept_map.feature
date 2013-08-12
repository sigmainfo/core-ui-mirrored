Feature: user toggles orientation of concept map
  In order to explore the concept map in a different way
  As a user browsing the concept map
  I want to toggle between a top-down or left-to-right layout for rendering

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
  
  Scenario: toggle orientation
    Given a concept "handgun"
    And this concept is narrower than "weapon"
    When I visit the single concept page for "handgun"
    Then I should see "handgun" being selected in the concept map
    And it should be connected to "weapon"
    And "weapon" should be rendered left of "handgun"
    When I click "Toggle orientation"
    Then "handgun" should still be selected
    And it should be connected to "weapon"
    But "weapon" should be rendered above "handgun"
