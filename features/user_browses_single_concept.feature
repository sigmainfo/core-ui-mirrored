@wip
Feature: user browses single concept
  In order to get all available information regarding a single concept
  As a user that browses the repository
  I want to see all terms, properties, edges and meta data of the concept

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: show details
    Given a concept with id "50005aece3ba3f095c000001" and label "handgun"
    And this concept has an English definition with value "A portable firearm"
    And this concept has an German definition with value "Tragbare Feuerwaffe"
    And this concept has a property "notes" with value "Bitte überprüfen!!!"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    And this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And the term "Schusswaffe" should have property "gender" with value "f"
    And given a broader concept with id "50005aece3ba3f095c000004" and a label "weapon"
    And given a narrower concept with id "50005aece3ba3f095c000002" and a label "pistol"
    And given a narrower concept with id "50005aece3ba3f095c000005" and a label "revolver"
    When I enter "gun" in the search field
    And I click the search button
    And I click on the label "handgun"
    Then I should be on the show concept page for id "50005aece3ba3f095c000001"
    And I should see the label "handgun"
    And I should see id "50005aece3ba3f095c000001"
    And I should see the section "Broader & Narrower"
    And this section should display "pistol" as being narrower
    And it should display "revolver" as being narrower
    And it should display "weapon" as being broader
    And I should see the section "Properties"
    And it should have an English property "Definition" with value "A portable firearm"  
    When I click on "de" for that property
    Then the value should have changed to "Tragbare Feuerwaffe"
    And it should have a property "notes" with value "Bitte überprüfen!!!"
    And I should see a section for locale "en"
    And it shoud have the following terms "gun", "firearm", "shot gun", "musket"
    And I should see a section for locale "de"
    And it shoud have the following terms "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And the term "Schusswaffe" should have a property "gender" with value "f"

  Scenario: toggle sections
    Given a concept with id "50005aece3ba3f095c000001" and label "handgun"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    When I click on the toggle of the locale "en"
    Then the locale should be hidden
    When I click on the toggle of the locale "en"
    Then I should see the term "gun"

  # Scenario: pin property locale
    
