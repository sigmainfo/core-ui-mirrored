Feature: user browses tree view
  In order to understand the hierarchy of the concept graph
  As a user browsing the concept map
  I want to see a top-down rendering of the concept tree

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: explore concept tree
    Given a concept "double action revolver with a swing out cylinder firing mechanism and barrel" exists
    And this concept is narrower than "weapon"
    When I visit the show concept page of this concept
    Then I should see a multiline label representing the currently selected concept within the concept map
    And I should see a label "weapon" above it
    And both concepts should be connected
