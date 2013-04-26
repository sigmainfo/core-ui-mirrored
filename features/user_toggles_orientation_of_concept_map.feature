Feature: user toggles orientation of concept map
  In order to meet my current demands
  As a user browsing the concept map
  I want to toggle top-down or left-to-right rendering

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  @wip
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
