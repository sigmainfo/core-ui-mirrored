Feature: user browses repository root node
  In order to clearly identify top level concepts
  As a user browsing the concept sphere
  I want to see a repository root node in the broader listing of a top level concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: browsing top level concept
    Given a top level concept "Top Gun" exists
    And the name of the current repository is "Top Movies from the 80ies"
    When I visit the show concept page for "Top Gun"
    Then I should see a single repository node within the broader listing
    And this repository node should have the name "Top Movies from the 80ies"
    When I click on this repository node
    Then I should be on the repository root page of "Top Movies from the 80ies"
