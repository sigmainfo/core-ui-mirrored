Feature: user browses concept map in source and target language
  In order to browse the concept map in different languages
  As a user browsing a selection of concepts
  I want to see the labels of all concept nodes in a selected language

  Background:
    Given I am a user of the repository
    And the repository provides the languages "English", "German", and "French"
    And I am logged in

  Scenario: switch concept labels
    Given a concept with English term "gun" and German term "Flinte"
    When I visit the concept details page
    And no source or target language is selected
    Then I should see a single node inside the concept map
    And the label of the node should read "gun"
    When I select "German" as source language
    Then the label of the node should read "Flinte"
    When I select "French" as source language
    Then the label of the node should read "gun"
    When I select "German" as target language
    Then the label of the node should read "Flinte"
