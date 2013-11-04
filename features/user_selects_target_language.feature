Feature: user selects target language
  In order to display and search terms from a target language
  As a user browsing the repository
  I want to set a search language

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: select target language
    Given the languages "English", "German", and "French" are available
    When I visit the repository root page
    Then I should see a widget "Languages"
    And I should see selection "None" for "Target language"
    When I click the "Target Language" selector
    Then I should see a dropdown with "None", "English", "German", and "French"
    When I select "German" from the dropdown
    Then I should see selection "German" for "Target language"
    And I should not see a dropdown
    When I reload the page
    Then I should see selection "German" for "Target language"
