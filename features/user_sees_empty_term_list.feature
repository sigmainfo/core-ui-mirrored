Feature: User sees empty term list
  In order to browse terms in alphabetical order
  As a user exploring the repository
  I want to see a widget for displaying terms

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  @wip
  Scenario: empty term list
    Given the languages "English", "German", and "French" are available
    When I visit the repository root
    And I click the "Source Language" selector
    And I select "None" from the dropdown
    Then I should see a widget "Term List"
    And this widget should contain "No language selected"
