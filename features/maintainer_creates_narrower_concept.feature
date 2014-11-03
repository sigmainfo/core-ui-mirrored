Feature: maintainer creates narrower concept
  In order to create a concept as narrower concept of an existing one
  As a maintainer who is adding data to the repository
  I want to create a new concept already connected to an exisiting concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And the repository defines an empty blueprint for concepts
    And I am logged in

  Scenario: create a narrower concept
    Given a concept with label "panopticum" exists
    When I visit the page of this concept
    And I toggle "EDIT MODE"
    Then I should see a button "Add narrower concept"
    When I click "Add narrower concept"
    Then I should be on the new concept page
    And I should see "panopticum" within the list of broader concepts
    When I click "Create concept"
    Then I should be on the show concept page
    And I should see the id of the newly created concept within the title
    And I should see "panopticum" within the list of broader concepts
    When I click on "panopticum"
    Then I should be on the show concept page of "panopticum"
    And I should see the id of the newly created concept within the list of narrower concepts

