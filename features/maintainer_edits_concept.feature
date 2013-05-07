@wip
Feature: maintainer edits concept
  In order to change meta data of an existing concept
  As a maintainer that is editing the repository
  I want to add, remove and change properties of a concept

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in
    And a concept with property "label" of "handgun" exists

  Scenario: toggle edit mode
    Given I have maintainer privileges
    When I visit the page of this concept
    And I click "Edit concept"
    And I should see edit buttons
    When I click "Edit concept"
    And I should not see edit buttons
