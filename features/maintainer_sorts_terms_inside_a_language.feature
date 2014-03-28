Feature: maintainer sorts terms inside a language
  In order to define the order of precedence of terms inside a language
  As a maintainer of the repository
  I want to sort the terms by dragging them to a specific position in the list

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And I am logged in

  @wip
  Scenario: edit order of precedece
    Given a concept with English terms "pistol", "handgun", and "revolver"
    And "revolver" has a precedence of 1
    And "pistol" has a precedence of 2
    And "handgun" has a precedence of 3
    When I visit the concept details page
    Then I see all 3 terms inside language "EN"
    And they have the following order: "revolver", "pistol", "handgun"
    When I toggle "EDIT MODE"
    Then I see a drag handler inside each term
    When I click on "Edit term" inside "pistol"
    Then I see no drag handlers anymore
    When I click on "Cancel
    Then I see a drag handler inside each term
    When I drag "handgun" to the top of the list
    Then the order of the terms has changed to "handgun", "revolver", "pistol"
    And I see an edit form with actions "Reset", "Cancel" and "Save precedence"
    And I do not see "Edit term" or "Remove term" inside any term
    When I click "Cancel"
    Then I do not see "Reset", "Cancel" or "Save precedence" anymore
    And the order of the terms is reverted to "revolver", "pistol", "handgun"
    But I see "Edit term" and "Remove term" inside each term
    When I drag "handgun" to the top of the list
    And I click "Reset"
    Then the order of the terms is reverted to "revolver", "pistol", "handgun"
    When I drag "handgun" to the top of the list
    And I click "Save precedence"
    Then I do not see "Reset", "Cancel" or "Save precedence" anymore
    But I see "Edit term" and "Remove term" inside each term
    When I reload the concept details page
    Then the order of the terms is still "handgun", "revolver", "pistol"
