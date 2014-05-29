Feature: maintainer edits concept
  In order to change meta data of an existing concept
  As a maintainer that is editing the repository
  I want to add, remove and change properties of a concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
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

  Scenario: reset properties form
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I change "Value" of property to "obsolescense"
    And I click "reset"
    Then I should see the key "label" and value "handgun"
    When I click "Remove property"
    And I click "Add property"
    And I click "reset"
    Then I should see only one property
    But I should see no property marked as deleted

  Scenario: cancel properties form
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I click "cancel"
    Then I should see no properties form

  Scenario: mark existing property as deleted
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I click "Remove property"
    Then I should see the property marked as deleted

  Scenario: create new property
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I click "Add property"
    Then I should see a new property

  Scenario: remove a new property
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I click "Add property"
    And I click "Remove property" on the new entry
    Then I should see only one property

  Scenario: validation errors
    When client-side validation is turned off
    And I toggle "EDIT MODE"
    And I click "Edit properties"
    And I change "Key" of property to ""
    And I click "Add property"
    And I click "Save concept"
    Then I should see an error summary
    And this summary should contain "Failed to save concept:"
    And this summary should contain "3 errors on properties"
    And I should see error "can't be blank" for input "Key" of existing property
    And I should see error "can't be blank" for input "Key" of new property
    And I should see error "can't be blank" for input "Value" of new property

  Scenario: not a maintainer
    Given I am no maintainer of the repository
    And I visit the page of this concept
    Then I should not see the edit concept button

  Scenario: change existing properties
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I change "Value" of property to "obsolescense"
    And I click "Save concept"
    Then I should see no properties form
    But I should see a property "LABEL" with value "obsolescense"

  Scenario: change existing properties
    When I toggle "EDIT MODE"
    And I click "Edit properties"
    And I click "Remove property"
    When I click "Save concept"
    Then I should see a confirmation dialog warning that one property will be deleted

