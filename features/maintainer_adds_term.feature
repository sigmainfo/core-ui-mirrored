Feature: maintainer adds term
  In order to make a new term available in context of a concept
  As a maintainer updating data in the repository
  I want to add a term to an existing concept

  Background:
    Given a concept exists
    And I am logged in as maintainer of the repository
    And I am on the edit concept details page

  @wip
  Scenario: add term
    When I click "Add term"
    And I fill in "Value" with "Dead Man"
    And I fill in "Language" with "en"
    And I click button "Add term"
    Then I see a term "Dead Man" inside the language section "EN"

  # Scenario: add term with property
  #   When I click "Add term"
  #   And I fill in the form
  #   And I click "Add property" inside the form
  #   And I fill in "Key" with "director"
  #   And I fill in "Value" with "Jim Jarmusch"
  #   And I click button "Add term"
  #   Then I see a term inside the language section "EN"
  #   When I click "Toggle properties" inside this term
  #   Then I see a property "director" with value "Jim Jarmusch"

  # Scenario: errors

  # Scenario: cancel
