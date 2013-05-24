Feature: user browses quicksearch results
  In order to quickly find a term, concept or taxonomy node
  As a user searching the repository
  I want to see the top matches for terms, concepts, and taxonomies

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: browse terms
    Given the following English terms: "dead", "man", "nobody", "poet", "poetic", "poetry", "train", "wild"
    And given the following German terms: "poetisch", "dichterisch", "Dichtkunst"
    And a concept "versify" that contains the terms "poetize" and "poetise"
    When I enter "poet" in the search field
    And I click the search button
    Then I should be on the search result page
    And I should see the query "poet" within the navigation
    And I should see a listing "TERMS"
    And the listing should contain "poet", "poetic", "poetisch", "poetise", "poetize", "poetry"
    And "poetic" should have language "EN"
    And "poetisch" should have language "DE"
    And "poetize" should have concept "versify"
    When I click on link to concept "versify"
    Then I should be on the page of concept "versify"

  Scenario: browse concepts
    Given the a concept with label "dead"
    And given a concept with label "versify"
    And that concept has the English term "poetize"
    And given a concept with label "poet"
    And given a concept with label "poem"
    And given a concept with label "poetry"
    And "poet" is a subconcept of "poetry"
    When I enter "poet" in the search field
    And I click the search button
    Then I should be on the search result page
    And I should see a listing "CONCEPTS"
    And the listing should contain "poet", "versify", "poetry"
    And "poet" should have superconcept "poetry"
    When I click on link to concept "poetry"
    Then I should be on the concept page of "poetry"

  # @wip
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
    And the listing should contain "poet", "poetry editor"
