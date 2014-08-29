Feature: user browses in source and target language
  In order to explore terms
  As a user browsing a concept
  I want to see the terms in source and target language first

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"

  Scenario: change label of concept by selected languages
    Given the languages "English", "German", "Russian", "Korean", and "French" are available
    And a concept
    And this concept hat the following Russian terms: "пистолет", "огнестрельное оружие"
    And this concept has the following English terms: "gun", "firearm"
    And this concept has the following Korean terms: "산탄 총", "총"
    And this concept has the following German terms: "Schusswaffe", "Flinte"
    And I am logged in

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
    Given the languages "English", "German", and "French" are available
    And a concept
    And this concept hat the Russian property "description": "пистолет"
    And this concept has the English property "description": "gun"
    And this concept has the Korean property "description": "산탄 총"
    And this concept has the German property "description": "Schusswaffe"
    And I am logged in

    When I click the "Source Language" selector
    And I select "None" from the dropdown
    And I click the "Target Language" selector
    And I select "None" from the dropdown

    And I am on this concept's page

    # No language selected
    Then I should see "пистолет" displayed as property "description" of concept
    And I should see the property "description" of concept in following language order: "Russian", "English", "Korean", "German"

    # Only source language selected
    When I click the "Source Language" selector
    And I select "German" from the dropdown

    Then I should see "Schusswaffe" displayed as property "description" of concept
    And I should see the property "description" of concept in following language order: "German", "Russian", "English", "Korean"

    # Both languages selected
    When I click the "Target Language" selector
    And I select "English" from the dropdown

    Then I should see "Schusswaffe" displayed as property "description" of concept
    And I should see the property "description" of concept in following language order: "German", "English", "Russian", "Korean"

    # Both languages selected, no property in source language
    When I click the "Source Language" selector
    And I select "French" from the dropdown

    Then I should see "gun" displayed as property "description" of concept
    And I should see the property "description" of concept in following language order: "English", "Russian", "Korean", "German"

    # Only target language selected
    When I click the "Source Language" selector
    And I select "None" from the dropdown
    When I click the "Target Language" selector
    And I select "German" from the dropdown

    Then I should see "Schusswaffe" displayed as property "description" of concept
    And I should see the property "description" of concept in following language order: "German", "Russian", "English", "Korean"



  Scenario: change properties of term by selected languages
    Given the languages "English", "German", and "French" are available
    And a concept with the English term "firearm"
    And this term hat the Russian property "description": "пистолет"
    And this term has the English property "description": "gun"
    And this term has the Korean property "description": "산탄 총"
    And this term has the German property "description": "Schusswaffe"
    And I am logged in

    When I click the "Source Language" selector
    And I select "None" from the dropdown
    And I click the "Target Language" selector
    And I select "None" from the dropdown

    And I am on this concept's page
    And I toggle the term's properties

    # No language selected
    Then I should see "пистолет" displayed as property "description" of term
    And I should see the property "description" of term in following language order: "Russian", "English", "Korean", "German"

    # Only source language selected
    When I click the "Source Language" selector
    And I select "German" from the dropdown
    And I toggle the term's properties

    Then I should see "Schusswaffe" displayed as property "description" of term
    And I should see the property "description" of term in following language order: "German", "Russian", "English", "Korean"

    # Both languages selected
    When I click the "Target Language" selector
    And I select "English" from the dropdown
    And I toggle the term's properties

    Then I should see "Schusswaffe" displayed as property "description" of term
    And I should see the property "description" of term in following language order: "German", "English", "Russian", "Korean"

    # Both languages selected, no property in source language
    When I click the "Source Language" selector
    And I select "French" from the dropdown
    And I toggle the term's properties

    Then I should see "gun" displayed as property "description" of term
    And I should see the property "description" of term in following language order: "English", "Russian", "Korean", "German"

    # Only target language selected
    When I click the "Source Language" selector
    And I select "None" from the dropdown
    When I click the "Target Language" selector
    And I select "German" from the dropdown
    And I toggle the term's properties

    Then I should see "Schusswaffe" displayed as property "description" of term
    And I should see the property "description" of term in following language order: "German", "Russian", "English", "Korean"
