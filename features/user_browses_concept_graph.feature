Feature: user browses concept graph
  In order to explore related concepts
  As a user browsing a selection of concepts
  I want to see a rendering of matching subtrees with broader and narrower concepts

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: explore concept tree
    Given a concept "handgun"
    And this concept is narrower than "weapon"
    And this concept is broader than "pistol", "revolver"
    And given a concept "long gun"
    And this concept is narrower than "weapon"
    And this concept is broader than "rifle"
    And "weapon", "pen" are narrower than "tool"
    When I enter the application
    Then I should see the widget "Concept Map"
    And it should be empty
    When I search for "handgun"
    And select "handgun" from the result list
    Then I shoud see "handgun" displayed in the concept map
    And I should see nodes for "pistol" and "revolver"
    And I should see a node "weapon"
    And I should see a node "long gun"
    And only "handgun" should be marked as being selected
    And "weapon" should be connected to "handgun"
    And "weapon" should be connected to "long gun"
    And "handgun" should be connected to "pistol"
    And "handgun" should be connected to "revolver"
    But I should not see "rifle"
    When I click to toggle the children of "long gun"
    Then I should see "rifle"
    And "long gun" should be connected to "rifle"
    When I click to toggle the children of "weapon"
    Then "weapon" should be the only node left
    And there should be no more connections
    When I click to toggle the parents of "weapon"
    Then I should see "tool"
    And I should see "pen"
    And "tool" should be connected to "weapon"
    And "tool" should be connected to "pen"
    When I click to toggle the parents of "weapon"
    Then "weapon" should be the only node left
  
  Scenario: hit list
    Given a concept "handgun"
    And a concept "hand"
    And a concept "handkerchief"
    When I search for "hand"
    Then I shoud see "handgun" displayed in the concept map
    And I should see a node "hand"
    And I should see a node "handkerch…"
    And all nodes should be classified as hits
  
  @wip
  Scenario: zoom and pan
    Given a concept "handgun"
    When I search for "handgun"
    Then I shoud see "handgun" displayed in the concept map
    When I click within the map
    And I scroll down
    Then "handgun" should be bigger
    When I scroll up
    Then "handgun" should be smaller
    
