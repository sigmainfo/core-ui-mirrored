Feature: user browses asset properties
  In order to learn about a concept or term
  As a user browsing the details of a single concept
  I want to see a list of asset properties for the concept and for each term

  Background:
    Given I am logged in as user of the repository

  @wip
  Scenario: browse concept's asset properties thumbnails
    Given the repository defines a blueprint for concept
    And that blueprint defines a property "image" of type "asset"
    And a concept "Crane" exists
    And that concept has a property "image" with caption "front view"
    And that concept has a property "image" with caption "side view"
    When I visit the concept details page for that concept
    And I look at the properties inside the concept header
    Then I see a property "IMAGE" that has two labels
    When I click on label "1"
    Then I see a thumbnail captioned "front view"
    When I click on label "2"
    Then I see a thumbnail captioned "side view"

  Scenario: browse term's asset property in asset viewer
    Given the repository defines a blueprint for term
    And that blueprint defines a property "image" of type "asset"
    And a term "Crane" exists
    And that term has a property "image" with caption "front view"
    When I visit the term details page for that term
    And I look at the properties inside the term header
    Then I see a property "IMAGE"
    And there is a thumbnail captioned "front view"
    When I click on the thumbnail
    Then I see a large view of the asset

  Scenario: download term's asset property
    Given the repository defines a blueprint for term
    And that blueprint defines a property "image" of type "asset"
    And a term "Crane" exists
    And that term has a property "image" with caption "front view"
    Then I visit the term details page for that term
    And I look at the properties inside the term header
    Then I see a property "IMAGE"
    And there is a thumbnail captioned "front view"
    Then I click on the thumbnail
    Then I see a large view of the asset
    And there is a download button on the asset viewer
    Then I click on the download button
    And I get a save file dialog box