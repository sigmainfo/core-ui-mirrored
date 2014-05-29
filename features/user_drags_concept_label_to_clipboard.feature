Feature: user drags concept label to clipboard
  As a convenient way to add any concept label to the clipboard
  I want to drag the concept label over the clipboard
  I want to see clearly what happens before dropping the element.

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    And a concept "panopticum" with super concept "surveillance" exists

  Scenario: drag concept label to clipboard
    Given I visit the home page
    And I search for "panopticum"
    Then I should see two draggable elements
    When I drag the label of "panopticum" into the clipboard
    Then I should see "panopticum" in clipboard
    When I click on the "surveillance" concept
    And I drag the title of the concept to the clipboard
    Then I should see "surveillance" in clipboard
    When I drag the title of the concept to the clipboard
    Then I still should see only one "surveillance" in clipboard
