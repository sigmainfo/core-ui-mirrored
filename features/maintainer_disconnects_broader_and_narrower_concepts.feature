Feature: maintainer disconnects broader and narrower concepts
  In order to disconnect a concept
  As a maintainer
  I want to drag a connected concept
  Out of the connection list

  Background:    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And I am logged in
    And a concept with label "panopticum" exists
    And a superconcept with label "surveillance" exists
    And a subconcept with label "camera" exists

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

