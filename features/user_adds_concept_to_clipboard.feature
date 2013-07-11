Feature: user adds concept to clipboard
  To be able to temporarely bookmark a concept
  A user can press a button
  To enlist the current concept in a clipboard

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    And a concept with label "panopticum" exists

  Scenario: add a concept to the clipboard
    Given I visit the page of this concept
    Then I should see a clipboard
    And the clipboard should be empty
    And I should see a button "Add to clipboard"
    When I click the button "Add to clipboard"
    Then I should see a link to the concept in the clipboard
