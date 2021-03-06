Feature: user browses asset properties
  In order to learn about a concept or term
  As a user browsing the details of a single concept
  I want to see a list of asset properties for the concept and for each term

  Background:
    Given I am logged in as user of the repository

  Scenario: browse concept's asset properties thumbnails
    Given the repository defines a blueprint for concept
    And that blueprint defines a property "image" of type "asset"
    And a concept "Crane" exists
    And that concept has a property "image" with caption "Crane: front view"
    And that concept has a property "image" with caption "Crane: side view"
    When I visit the concept details page for that concept
    And I look at the properties inside the concept header
    Then I see a property "IMAGE" that has two thumbnails
    And I see a thumbnail captioned "Crane: front view"
    And I see a thumbnail captioned "Crane: side view"

  Scenario: browse concept's multilingual asset properties thumbnails
    Given the repository defines a blueprint for concept
    And that blueprint defines a property "image" of type "asset"
    And a concept "Crane" exists
    And that concept has a property "image" with caption "Crane: front view" and language "EN"
    And that concept has a property "image" with caption "Kran: Vorderansicht" and language "DE"
    When I visit the concept details page for that concept
    And I look at the properties inside the concept header
    Then I see a property "IMAGE" with tabs "EN", "DE"
    Then I click on "EN"
    And I see a thumbnail captioned "Crane: front view"
    Then I click on "DE"
    And I see a thumbnail captioned "Kran: Vorderansicht"

  Scenario: download term's asset property through asset viewer
    Given the repository defines a blueprint for term
    And that blueprint defines a property "image" of type "asset"
    And a term "Crane" exists
    And this term has a property "image" with caption "Crane: front view"
    When I visit the concept details page for that concept
    And I click on toggle "PROPERTIES" inside the term "Crane"
    Then I see a property "IMAGE"
    And there is a thumbnail captioned "front view"
    When I click on the thumbnail
    Then I see a large view of the asset
    And I see a download link

  Scenario: view and download non-image asset property
    Given the repository defines a blueprint for concept
    And that blueprint defines a property "manual" of type "asset"
    And a concept "Crane" exists
    And that concept has a property "manual" with caption "Tech manual"
    When I visit the concept details page for that concept
    And I look at the properties inside the concept header
    Then I see a property "MANUAL" that has one thumbnail
    And I see a generic thumbnail captioned "Tech manual"
    When I click on the generic thumbnail
    Then I see a download link for the file
