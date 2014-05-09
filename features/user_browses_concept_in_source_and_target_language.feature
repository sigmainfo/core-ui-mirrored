Feature: user browses concept in source and target language
  In order to explore terms
  As a user browsing a concept
  I want to see the terms in source and target language first

  Background:
    Given I am a user of the repository
    And the repository provides the languages "English", "German", and "French"
    And I am logged in

  Scenario: change label of concept by selected languages
    Given the languages "English", "German", "Russian", "Korean", and "French" are available
    And a concept
    And this concept has the following Russian terms: "пистолет", "огнестрельное оружие"
    And this concept has the following English terms: "gun", "firearm"
    And this concept has the following Korean terms: "산탄 총", "총"
    And this concept has the following German terms: "Schusswaffe", "Flinte"
    When I click the "Source Language" selector
    And I select "None" from the dropdown
    And I click the "Target Language" selector
    And I select "None" from the dropdown
    And I am on this concept's page
    Then I should see the languages in alphabetic order: "DE", "EN", "KO", "RU"
    When I click the "Source Language" selector
    And I select "Korean" from the dropdown
    Then I should see the languages in following order: "KO", "DE", "EN", "RU"
    When I click the "Target Language" selector
    And I select "English" from the dropdown
    Then I should see the languages in following order: "KO", "EN", "DE", "RU"
    When I click the "Source Language" selector
    And I select "None" from the dropdown
    Then I should see the languages in following order: "EN", "DE", "KO", "RU"
    When I click the "Source Language" selector
    And I select "French" from the dropdown
    Then I should see the languages in following order: "FR", "EN", "DE", "KO", "RU"
    And I should see "No terms for this language" in the French section

  Scenario: change properties of concept by selected languages
    Given the following languages are available: "German", "English", "French"
    And a concept with a multilingual property "description" exists
    And this property has values for Greek, German, and English
    When I visit the concept details page
    And no source or target language is selected
    Then I should see language tabs for "description" in order: "DE", "EN", "EL"
    And the first tab should be selected
    When I select "English" as source language
    Then the language tabs should have changed order to: "EN", "DE", "EL"
    And the first tab should be selected

  Scenario: browse term property groups by language
    Given a concept with an English term "rose" exists
    And it has an English description "A rose is a rose."
    And it has a German description "Eine Rose ist eine Rose."
    And it has a French description "Une rose est une rose."
    And it has a Greek description "Ένα τριαντάφυλλο είναι ένα τριαντάφυλλο."
    When I visit the details page of this concept
    And I select "English" as source language
    And I select "French" as target language
    And I click "Toggle properties" on the term
    Then I see a property group "DESCRIPTION"
    And I see tabs "EN", "FR", "DE", "EL" in order
    And the English description "A rose is a rose." is selected
    When I select "German" as source language
    And I click "Toggle properties" on the term
    Then I see tabs "DE", "FR", "EN", "EL" in order
    And the German description "Eine Rose ist eine Rose." is selected
    When I select "None" as source language
    When I select "None" as target language
    And I click "Toggle properties" on the term
    Then I see tabs "DE", "EN", "FR", "EL" in order
