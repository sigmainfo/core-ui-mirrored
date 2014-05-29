Feature: maintainer disconnects broader and narrower concepts
  In order to disconnect a concept
  As a maintainer
  I want to drag a connected concept
  Out of the connection list

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And I am logged in
    And a concept with label "panopticum", superconcept "surveillance" and subconcept "camera" exists
    And I am on the show concept page of "panopticum"
    And I toggle "EDIT MODE"
    And I click "Edit broader & narrower concepts"

  @firefox
  Scenario: disconnect broader and narrower concepts
    Given I drag "surveillance" out of the super concept list
    Then I should see no super concept anymore
    Given I drag "camera" out of the sub concept list
    Then I should see no sub concept anymore

  Scenario: reset and cancel
    Given I drag "surveillance" out of the super concept list
    And I drag "camera" out of the sub concept list
    When I click Reset
    Then I should see "surveillance" as broader concept
    And I should see "camera" as narrower concept
    When I drag "surveillance" out of the super concept list
    And I drag "camera" out of the sub concept list
    And I click Cancel
    Then I should not be in edit mode anymore
    But still see "surveillance" as broader and "camera" as narrower concept

  @firefox
  Scenario: save changes
    Given I drag "surveillance" out of the super concept list
    And I drag "camera" out of the sub concept list
    When I click Save
    Then I should not be in edit mode anymore
    And I should see no broader and narrower concepts anymore

  Scenario: edge cases
    Given I drag "camera" to the clipboard
    And I drag "camera" out of the sub concept list
    When I drag "camera" back to the sub concept list
    Then I should see "camera" as narrower concept
    When I drag "camera" out of the sub concept list
    And I drag "camera" back to the sub concept list
    Then I should see "camera" as narrower concept
    When I drag "camera" out of the sub concept list
    And I drag "camera" to the super concept list
    Then I should see "camera" as broader concept
    When I drag "camera" out of the super concept list
    And I drag "camera" back to the sub concept list
    Then I should see "camera" as narrower concept
