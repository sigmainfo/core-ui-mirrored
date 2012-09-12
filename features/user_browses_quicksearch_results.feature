Feature: User browses quicksearch results
  In order to quickly find a term, concept or taxonomy node
  As a user searching the repository
  I want to see the top matches for terms, concepts, and taxonomies

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: browse terms
    Given the following English terms: "dead", "man", "nobody", "poet", "poetic", "poetise", "poetize", "poetry", "train", "wild"
    And given the following German terms: "poetisch", "dichterisch", "Dichtkunst"
    And a concept with id "50005aece3ba3f095c000001" that contains the terms "poetize" and "poetise"
    When I enter "poet" in the search field
    And I click the search button
    Then I should be on the search result page
    And I should see the query "poet" within the navigation
    And I should see a listing "TERMS"
    And the listing should contain "poet", "poetic", "poetisch", "poetise", "poetize", "poetry"
    And "poetic" should have language "EN"
    And "poetisch" should have language "DE"
    And "poetize" should have concept "50005aece3ba3f095c000001"
    When I click on link to concept "50005aece3ba3f095c000001"
    Then I should be on the page of concept "50005aece3ba3f095c000001"

  Scenario: browse concepts
    Given the a concept with id "50005aece3ba3f095c000001" and label "dead"
    And given a concept with id "50005aece3ba3f095c000002" and label "versify"
    And that concept has the English term "poetize"
    And given a concept with id "50005aece3ba3f095c000003" and label "poet"
    And given a concept with id "50005aece3ba3f095c000004" and label "poem"
    And given a concept with id "50005aece3ba3f095c000005" and label "poetry"
    And "poem" is a subconcept of "poetry"
    When I enter "poe" in the search field
    And I click the search button
    Then I should be on the search result page
    And I should see a listing "CONCEPTS"
    And the listing should contain "poet", "poem", "poetry", "versify"
    And "poem" should have id "50005aece3ba3f095c000004"
    And "poem" should have superconcept "poetry"
    When I click on link to concept "poetry"
    Then I should be on the concept page of "poetry"

  Scenario: browse taxonomies
    Given a taxonomy "Professions"
    And this taxonomy has a node "programmer"
    And this taxonomy has a node "artist"
    And this taxonomy has a node "poet"
    And "poet" is a subnode of "artist"
    And this taxonomy has a node "poetry editor"
    When I enter "poet" in the search field
    And I click the search button
    Then I should be on the search result page
    And I should see a listing "TAXONOMIES"
    And the listing should contain "poet", "poetry editor", "artist"
