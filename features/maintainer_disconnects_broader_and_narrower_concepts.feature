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

  Scenario: disconnect broader and narrower concepts
    Given I am on the show concept page of "panopticum"
    And I click "Edit concept"
    And I click "Edit concept connections"
    When I drag "surveillance" out of the super concept list
    Then I should see no super concept anymore
    When I drag "camera" out of the sub concept list
    Then I should see no sub concept anymore
