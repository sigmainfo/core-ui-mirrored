@wip
Feature: user browses concept graph
  In order to explore related concepts
  As a user browsing a selection of concepts
  I want to see a rendering of matching subtrees with broader and narrower concepts

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: explore single concept
    Given a concept "handgun"
    And this concept is narrower than "weapon"
    And this concept is broader than "pistol", "revolver"
    And given a concept "long gun"
    And this concept is narrower than "weapon"
    And this concept is broader than "rifle"
    When I enter the application
    Then I should see the widget "Concept Map"
    And it should be empty
    When I search for "handgun"
    And select "handgun" from the result list
    Then I shoud see "weapon", "handgun", "long gun", "pistol", and "revolver" displayed in the concept map
    And "handgun" should be marked as being selected
    And "weapon" should be connected to "handgun"
    And "weapon" should be connected to "long gun"
    And "handgun" should be connected to "pistol"
    And "handgun" should be connected to "revolver"
    But I should not see "rifle"
    When I click to toggle the children of "long gun"
    Then I should see "rifle"
    And "rifle" should be connected to "handgun"
 

