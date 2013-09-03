Feature: maintainer connects concept from clipboard
  In order to connect a concept to another concept
  As a maintainer
  I want to drag a clipped concept
  To a defined drop area

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And I am logged in
    And a concept with label "panopticum" exists
    And a concept with label "surveillance" exists

  Scenario: connect a concept as subconcept
    Given I search for "panopticum"
    And I drag the search result to the clipboard
    And I search for "surveillance"
    And I click on the search result
    And I click "Edit concept"
    And I click "Edit concept connections"
    And I drag the clipped concept to the subconcept dropzone
    Then I should see "panopticum" unsaved as narrower concept
    And I should see reset, cancel and save buttons
    When I click save
    Then the concept should have a new narrower connection

  Scenario: connect a concept as superconcept
    Given I search for "panopticum"
    And I drag the search result to the clipboard
    And I search for "surveillance"
    And I click on the search result
    And I click "Edit concept"
    And I click "Edit concept connections"
    And I drag the clipped concept to the superconcept dropzone
    Then I should see "panopticum" unsaved as broader concept
    And I should see reset, cancel and save buttons
    When I click save
    Then the concept should have a new broader connection

  Scenario: reset and cancel form
    Given I search for "panopticum"
    And I drag the search result to the clipboard
    And I search for "surveillance"
    And I click on the search result
    And I click "Edit concept"
    And I click "Edit concept connections"
    And I drag the clipped concept to the superconcept dropzone
    And I click Reset
    Then I should not see any unsaved concepts
    When I drag the clipped concept to the superconcept dropzone
    And I click Cancel
    Then I should not see any unsaved concepts
    And I should not see drop zones
   
