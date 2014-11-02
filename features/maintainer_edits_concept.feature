Feature: maintainer edits concept
  In order to change meta data of an existing concept
  As a maintainer that is editing the repository
  I want to add, remove and change properties of a concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And the repository defines a blueprint for concepts
    And that blueprint requires a property "label" of type "text"
    And I am logged in
    And a concept with property "label" of "handgun" exists
    And I visit the page of this concept

  Scenario: toggle edit mode
    When I toggle "EDIT MODE"
    Then I should see edit buttons
    When I toggle "EDIT MODE"
    Then I should not see edit buttons

  Scenario: toggle properties form
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    Then I should see a properties form
    When I toggle "EDIT MODE"
    Then I should see no properties form
    When I toggle "EDIT MODE"
    Then I should see a properties form

  @wip
  Scenario: cancel properties form
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I click "cancel"
    Then I should see no properties form

  Scenario: not a maintainer
    Given I am no maintainer of the repository
    And I visit the page of this concept
    Then I should not see the edit concept button

  Scenario: change existing properties
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I change property "label" to "obsolescense"
    And I click "Save concept"
    Then I should see no properties form
    But I should see a property "LABEL" with value "obsolescense"

