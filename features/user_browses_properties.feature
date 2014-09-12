Feature: user browses properties
  In order to learn about a concept or term
  As a user browsing the details of a single concept
  I want to see a list of properties for the concept and for each term

  Background:
    Given I am logged in as user of the repository

  Scenario: browse concept properties
    Given the repository defines a blueprint for concept
    And that blueprint defines a property "dangerous" of type "boolean"
    And that blueprint defines a property "definition" of type "text"
    And a concept "Vampire" exists
    And that concept has the property "dangerous" set to be true
    And that concept has the property "alias" set to "Lamia"
    When I visit the concept details page for that concept
    And I look at the properties inside the concept header
    Then I see a property "DANGEROUS" that is checked
    And I see a property "DEFINITION" that is empty
    And I see a property "ALIAS" with value "Lamia"

  @wip
  Scenario: browse term properties
    Given the repository defines a blueprint for term
    And that blueprint defines a property "status" of type "picklist"
    And that property allows values: "accepted", "forbidden", "deprecated"
    And a concept with term "vampire" exists
    And that term has the property "status" set to "accepted"
    When I visit the concept details page for that concept
    And I click on toggle "PROPERTIES" inside the term "vampire"
    Then I see a listing of properties inside that term
    And this listing contains a picklist "STATUS" with value "accepted"

  # @wip
  # Scenario: browse multilang property
  #   Given a concept "Vampire" exists
  #   And that concept has a property "definition"
  #   And the English value is set to "corpse that drinks blood of the living"
  #   And the German value is set to "Untoter Blutsauger, mythische Gestalt"
  #   When I visit the concept details page for that concept
  #   And I look at the properties inside the concept header
  #   Then I see a property "DEFINITION" with tabs "en", "de"
  #   When I click on "en" then I see "corpse that drinks blood of the living"
  #   When I click on "de" then I see "Untoter Blutsauger, mythische Gestalt"

  # @wip
  # Scenario: toggle all term properties
  #   Given a concept "Vampire" exists
  #   And that concept has a German term "Vampir"
  #   And that term has the property "status" set to "accepted"
  #   And that concept has a Greek term "βρυκόλακας"
  #   And that term has the property "status" set to "accepted"
  #   When I visit the concept details page for that concept
  #   And I click on "TOGGLE ALL PROPERTIES"
  #   Then I should see the property "status" for both terms
