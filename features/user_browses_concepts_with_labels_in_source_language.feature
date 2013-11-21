Feature: user browses concepts with labels in source language
  In order to explore related concepts
  As a user browsing a selection of concepts
  I want to see a rendering of matching subtrees with broader and narrower concepts

  Scenario: explore concept tree
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And the languages "English", "German", and "French" are available
    And a concept
    And this concept has the following English terms: "gun", "firearm"
    And this concept has the following German terms: "Schusswaffe", "Flinte"
    And I am logged in

    When I click the "Source Language" selector
    And I select "None" from the dropdown
    And I click the "Target Language" selector
    And I select "None" from the dropdown

    And I enter "firearm" in the search field
    And I click the search button
    Then I should see the concept hit "gun"
    And I should not see the concept hit "Schusswaffe"
    And I should see a concept node "gun" inside the concept map

    When I click the "Source Language" selector
    And I select "German" from the dropdown
    Then I should see the concept hit "Schusswaffe"
    And I should not see the concept hit "gun"
    And I should see a concept node "Schusswaffe" inside the concept map

    When I click the "Source Language" selector
    And I select "French" from the dropdown
    Then I should see the concept hit "gun"
    And I should not see the concept hit "Schusswaffe"
    And I should see a concept node "gun" inside the concept map

    When I click the "Source Language" selector
    And I select "None" from the dropdown
    And I click the "Target Language" selector
    And I select "German" from the dropdown

    Then I should see the concept hit "Schusswaffe"
    And I should not see the concept hit "gun"
    And I should see a concept node "Schusswaffe" inside the concept map
