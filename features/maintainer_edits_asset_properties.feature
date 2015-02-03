Feature: maintainer edits asset properties
  In order to better describe a concept or a term
  As a maintainer editing the details of a single concept/term
  I want to be able to add/remove a list of asset properties for the concept and for each term

  Background:
    Given I am logged in as maintainer of the repository

  Scenario: add required asset property to new concept
    Given the repository defines a blueprint for concept
    And that blueprint defines a property "image" of type "asset"
    When I visit the repository root page
    And I click on "New concept"
    Then I see a section "PROPERTIES" within the form "Create concept"
    And I see a fieldset "IMAGE" within this section
    And this fieldset contains a file input
    And this fieldset contains a select "LANGUAGE"
