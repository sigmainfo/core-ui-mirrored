Feature: user toggles main view
  In order to concentrate on a certain aspect of the data
  As a user browsing a repository
  I want to maximize a widget inside the main area

  Background:
    Given I am logged in as user of the repository

  @wip
  Scenario: toggle concept map
    Given a concept "Monitor" exists
    And this concept has narrower concepts "LCD Screen" and "TFT Screen"
    And I visit the repository root page
    When I search for "screen"
    Then I should see a widget "Concept Map"
    And it should contain nodes "Monitor", "LCD Screen", and "TFT Screen"
    And I should see listing "Concepts" inside the main view
    And it should contain items "LCD Screen" and "TFT Screen"
    When I click on "Maximize" inside the widget "Concept Map"
    Then I should not see a widget "Concept Map"
    But I should see a concept map inside the main view
    And it should contain nodes "Monitor", "LCD Screen", and "TFT Screen"
    And I should see a widget "Concepts"
    And it should contain items "LCD Screen" and "TFT Screen"
    When I click on "Maximize" inside the widget "Concepts"
    Then I should not see a widget "Concepts"
    And I should see listing "Concepts" inside the main view
    And it should contain items "LCD Screen" and "TFT Screen"
    And I should see a widget "Concept Map"
    And it should contain nodes "Monitor", "LCD Screen", and "TFT Screen"

  @wip
  Scenario: step thru widgets
    Given I visit the repository root page
    When I click on "Maximize" inside the widget "Clipboard"
    Then I should not see a widget "Clipboard"
    But I should see a widget "Concepts"
    And I should see a caption "CLIPBOARD" inside the main view
    When I click on "Maximize" inside the widget "Term List"
    Then I should not see a widget "Term List"
    But I should see a widget "Clipboard"
    And I should see a caption "TERM LIST" inside the main view
