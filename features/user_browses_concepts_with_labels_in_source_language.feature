Feature: user browses concepts with labels in source language
  In order to explore related concepts
  As a user browsing a selection of concepts
  I want to see a rendering of matching subtrees with broader and narrower concepts

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: explore concept tree
    Given a concept
    And this concept has the following English terms: "gun", "firearm"
    And this concept has the following German terms: "Schusswaffe", "Flinte"

    When I click the "Source Language" selector
    And I select "None" from the dropdown
    
    And I enter "firearm" in the search field
    And I click the search button
    Then I should see the concept hit "gun"
    And I should not see the concept hit "Schusswaffe"
    
    When I click the "Source Language" selector
    And I select "German" from the dropdown
    Then I should see the concept hit "Schusswaffe"
    And I should not see the concept hit "gun"
    
    When I click the "Source Language" selector
    And I select "French" from the dropdown
    Then I should see the concept hit "gun"
    And I should not see the concept hit "Schusswaffe"