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
    But the clipboard should be empty
    And I should see a button "Add to clipboard"
    When I click the button "Add to clipboard"
    Then I should see a link to the concept in the clipboard

  Scenario: clipboard is not preserved
    Given I visit the page of this concept
    And I click the button "Add to clipboard"
    Then I should see a link to the concept in the clipboard
    When I visit the page of this concept
    Then the clipboard should be empty

  Scenario: hit is highlighted
    Given I visit the page of this concept
    When I click the button "Add to clipboard"
    Then the clip should be highlighted as hit
    When I search for "handgun"
    Then I should be on the search result page
    And the clip should not be highlighted
    When I search for "panopticum"
    Then I should be on the search result page
    Then the clip should be highlighted as hit

  Scenario: clear the clipboard
    Given I visit the page of this concept
    Then I should see a button "Clear" as clipboard action
    When I click the button "Add to clipboard"
    Then I should see a link to the concept in the clipboard
    When I click the button "Clear"
    Then the clipboard should be empty
