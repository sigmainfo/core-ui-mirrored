@wip
Feature: user browses list of concepts
  In order to find relevant concepts
  As a user that searches the repository
  I want to see a list of matching concepts and their most essential data

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: expand search results
    Given a concept with id "50005aece3ba3f095c000001" defined as "A portable firearm"
    And this concept has the label "handgun"
    And this concept has the following English terms: "gun", "firearm", "shot gun", "musket"
    And this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And given another concept with id "50005aece3ba3f095c000002" defined as "a handgun whose chamber is integral with the barrel;"
    And this concept has the following English terms: "pistol", "gun", "automatic pistol"
    And this concept is a subconcept of "handgun"
    When I enter "gun" in the search field
    And I click the search button
    And I click "Show all" within the concept search results
    Then I should be on the search result page for concepts
    And I should see a concept "handgun" with id "50005aece3ba3f095c000001"
    And I should see it being defined as "A portable firearm"
    And I should see it having the following English terms: "gun", "firearm", "shot gun", "musket"
    And I should see it having the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"
    And I should see a concept "pistol" with id "50005aece3ba3f095c000002"
    And I should see it being narrower than "handgun"

  Scenario: concept search by term
    When I select "Concepts by Terms" as the type of search
    And I enter "gun" in the search field
    And I click the search button
    Then I should be on the search result page for concepts
    And the target should be "terms"
    And the query should be "gun"
  
  Scenario: concept search by definition
    When I select "Concepts by Definition" as the type of search
    And I enter "gun" in the search field
    And I click the search button
    Then I should be on the search result page for concepts
    And the target should be "definition"
    And the query should be "gun"
