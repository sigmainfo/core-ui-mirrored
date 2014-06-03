Feature: user browses single concept
  In order to get all available information regarding a single concept
  As a user that browses the repository
  I want to see all terms, properties, edges and meta data of the concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: show details
    Given a concept with label "handgun"
    And this concept has an English definition with value "A portable firearm"
    And this concept has an German definition with value "Tragbare Feuerwaffe"
    And this concept has a property "notes" with value "Bitte überprüfen!!!"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    And this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And the term "Schusswaffe" should have property "gender" with value "f"
    And given a broader concept with label "weapon"
    And given a narrower concept with label "pistol"
    And given a narrower concept with label "revolver"
    When I enter "gun" in the search field
    And I click the search button
    And I click on the label "handgun"
    Then I should be on the show concept page for "handgun"
    And I should see the label "handgun"
    And I should see the section "BROADER & NARROWER"
    And this section should display "pistol" as being narrower
    And it should display "revolver" as being narrower
    And it should display "weapon" as being broader
    And I should see the section "PROPERTIES"
    And it should have an English property "DEFINITION" with value "A portable firearm"
    When I click on "de" for that property
    Then the value should have changed to "Tragbare Feuerwaffe"
    And it should have a property "notes" with value "Bitte überprüfen!!!"
    And I should see a section for locale "EN"
    And it shoud have the following terms "gun", "firearm", "shot gun", "musket"
    And I should see a section for locale "DE"
    And it shoud have the following terms "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    When I click on toggle "PROPERTIES" of term "Schusswaffe"
    Then I should see property "GENDER" with value "f"

  Scenario: toggle sections
    Given a concept with label "handgun"
    And this concept has a property "notes" with value "Bitte überprüfen!!!"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    And given a broader concept with label "weapon"
    When I enter "gun" in the search field
    And I click the search button
    And I click on the label "handgun"
    When I click on the toggle of the locale "EN"
    Then the locale should be hidden
    When I click on the toggle of the locale "EN"
    Then I should see the term "gun"
    When I click on the toggle "BROADER & NARROWER"
    Then the section "BROADER & NARROWER" should be hidden
    When I click on the toggle "PROPERTIES"
    Then the concept properties should be hidden

  Scenario: toggle all term properties
    Given a concept with label "handgun"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    And this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And the term "Schusswaffe" should have property "gender" with value "f"
    And the term "Flinte" should have property "status" with value "pending"
    When I enter "gun" in the search field
    And I click the search button
    And I click on the label "handgun"
    Then I should be on the show concept page for "handgun"
    When I click on toggle "TOGGLE ALL PROPERTIES"
    Then I should see property "GENDER" with value "f"
    Then I should see property "status" with value "pending"

  Scenario: browse system info
    Given a concept with label "handgun"
    And this concept has a property "notes" with value "Bitte überprüfen!!!"
    And this property has an attribute "author" of "William"
    And this concept has a property "notes" with value "I'm not dead. Am I?"
    And this property has an attribute "author" of "Nobody"
    And this concept has a term "shot gun"
    And this term has an attribute "legacy_id" of "543"
    And this term has a property "parts of speach" with value "noun"
    And this property has an attribute "author" of "Mr. Blake"
    When I enter "gun" in the search field
    And I click the search button
    And I click on the label "handgun"
    And I click on the toggle "PROPERTIES" for term "shot gun"
    When I click the toggle "System Info" on the concept
    Then I should see "id" of the "handgun" concept
    And I should see "legacy_id" with value "543" for term "shot gun"
    And I should see "author" with value "Mr. Blake" for property "parts of speach"
    And I should see "author" with value "William" for property "notes"
    When I click on index item "2" for property "NOTES"
    Then I should see "author" with value "Nobody" for property "NOTES"
    When I click the toggle "System Info" on the concept
    Then I should not see information for "id", "author", and "legacy_id"
