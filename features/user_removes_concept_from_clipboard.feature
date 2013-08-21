Feature: user removes concept from clipboard
  To be able to remove temporary bookmarked concepts
  A user can press a button
  To remove the current concept from the clipboard

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    And a concept with label "panopticum" exists

  Scenario: remove a concept from the clipboard
    Given I visit the page of this concept
    And I click the button "Add to clipboard"
    Then I should see one clipboard entry "panopticum"
    And I should see a button "Remove from clipboard"
    When I click the button "Remove from clipboard"
    Then the clipboard should be empty
