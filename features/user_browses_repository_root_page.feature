@wip
Feature: user browses repository root page
  In order to learn more about the currently selected repository
  As a user browsing concepts and terms
  I want to see relevant meta data and information

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: default repository
    Given I am manager of a repository "The Art of War", "Ancient Chinese military treatise"
    And this repository has the copyright string "(c) 512 BC SunTzu"
    And it's info text reads "Verses from the book occur in modern daily Chinese idioms and phrases."
    When I visit the repository root page
    Then I should see the title "The Art of War" with description "Ancient Chinese military treatise"
    And I should see a table containing the meta data for "CREATED AT", "COPYRIGHT", and "INFO" 
    And I should see a section "CONTACT" with my "NAME" and "EMAIL" listed
