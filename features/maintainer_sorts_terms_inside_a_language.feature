Feature: maintainer sorts terms inside a language
  In order to define the precedence terms inside a language
  As a maintainer of the repository
  I want to sort the terms by dragging them to a specific position in the list

  Background:
    Given I am logged in as a maintainer of the repository

  @wip
  Scenario: edit order of precedece
    Given a concept with English terms "handgun" and "firearm" exists
    When I visit the concept details page
    Then I see the terms in following order: "handgun", "firearm"
    When I toggle "EDIT MODE"
    Then I see a drag handler for each term
    When I drag "firearm" above "handgun"
    Then I see the terms in following order: "firearm", "handgun"
    And I see a form with actions "Reset", "Cancel" and "Save precedence"
    When I click "Save precedence"
    Then I do not see the form anymore
    And I see the terms in following order: "firearm", "handgun"

  @wip
  Scenario: switching editing states
    Given a concept with English terms "handgun" and "firearm" exists
    When I visit the concept details page
    And I toggle "EDIT MODE"
    Then I see a drag handler for each term
    And I see "Edit term" and "Remove term" actions for every term
    When I drag "firearm" above "handgun"
    Then I do not see any "Edit term" or "Remove term" actions
    But I see a drag handler for each term
    When I click "Cancel"
    Then I see "Edit term" and "Remove term" actions for every term
    And I see a drag handler for each term
    When I click "Edit term"
    Then I do not see any drag handlers for terms
    When I click "Cancel"
    Then I see a drag handler for each term
    And I see "Edit term" and "Remove term" actions for every term

  @wip
  Scenario: reset and cancel
    Given a concept with English terms "handgun" and "firearm" exists
    When I visit the concept details page
    And I toggle "EDIT MODE"
    And I drag "firearm" above "handgun"
    Then I see the terms in following order: "firearm", "handgun"
    And I see a form with actions "Reset", "Cancel" and "Save precedence"
    When I click "Reset"
    Then I see the terms in following order: "handgun", "firearm"
    And I see a form with actions "Reset", "Cancel" and "Save precedence"
    When I drag "firearm" above "handgun"
    And I click "Cancel"
    Then I should not see the form anymore
    And I see the terms in following order: "handgun", "firearm"
