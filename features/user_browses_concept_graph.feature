Feature: user browses concept graph
  In order to explore related concepts
  As a user browsing a selection of concepts
  I want to see a rendering of matching subtrees with broader and narrower concepts

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: explore concept tree
    Given a concept "handgun"
    And this concept is narrower than "weapon"
    And "weapon" is narrower than "tool"
    When I enter the application
    Then I should see the widget "Concept Map"
    And it should show the repository root node only
    When I search for "handgun"
    And select "handgun" from the result list
    Then I should see "handgun" displayed in the concept map
    And I should see a node "weapon"
    And only "handgun" should be marked as being selected
    And "weapon" should be connected to "handgun"
    And I should see a node "tool"
    And "tool" should be connected to "weapon"
    And the repository root node should be connected to "tool"

  Scenario: hit list
    Given a concept "handgun"
    And a concept "hand"
    And a concept "handkerchief"
    When I enter the application
    And I search for "hand"
    Then I should see "handgun" displayed in the concept map
    And I should see a node "hand"
    And I should see a node "handkerchief"
    And all nodes should be classified as hits

  Scenario: zoom and pan
    Given a concept "handgun"
    When I enter the application
    And I search for "handgun"
    Then I should see "handgun" displayed in the concept map
    When I click on "Zoom in"
    Then "handgun" should be bigger
    When I click on "Zoom out"
    Then "handgun" should have the original size again

