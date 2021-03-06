Feature: user browses list of concepts
  In order to find relevant concepts
  As a user that searches the repository
  I want to see a list of matching concepts and their most essential data

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: expand search results
    Given a concept defined as "A portable firearm"
    And this concept has the label "handgun"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    And this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And given another concept defined as "a handgun whose chamber is integral with the barrel;"
    And this concept has the following English terms: "pistol", "gun", "automatic pistol"
    And this concept is a subconcept of "handgun"
    When I visit the repository root page
    And I enter "gun" in the search field
    And I click the search button
    And I select "German" as source language
    And I select "English" as target language
    Then I should be on the search result page for concepts with query "gun"
    And I should see a concept "handgun"
    And I should see it being defined as "A portable firearm"
    And I should see it having the following English terms: "firearm", "gun", "musket", "shot gun"
    And I should see it having the following German terms: "Flinte", "Geschütz", "Pistole", "Schießgewehr", "Schusswaffe"
    And I should see a concept "pistol"
    And I should see it being narrower than "handgun"

  Scenario: concept search by term
    When I select "Concepts by Terms" as the type of search
    And I enter "gun" in the search field
    And I click the search button
    Then I should be on the search result page for concepts with target "terms" and query "gun"

  Scenario: concept search by definition
    When I select "Concepts by Definition" as the type of search
    And I enter "gun" in the search field
    And I click the search button
    Then I should be on the search result page for concepts with target "definition" and query "gun"
