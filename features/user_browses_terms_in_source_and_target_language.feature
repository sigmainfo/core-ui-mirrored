Feature: user browses terms in source and target language 
  In order to explore terms
  As a user browsing a concept
  I want to see the terms in source and target language first

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    
  Scenario: explore concept tree
    Given the languages "English", "German", and "French" are available
    And a concept
    And this concept hat the following Russian terms: "пистолет", "огнестрельное оружие"
    And this concept has the following English terms: "gun", "firearm"
    And this concept has the following Korean terms: "산탄 총", "총"
    And this concept has the following German terms: "Schusswaffe", "Flinte"

    When I click the "Source Language" selector
    And I select "None" from the dropdown
    And I click the "Target Language" selector
    And I select "None" from the dropdown
    
    And I am on this concept's page
    
    Then I should see the Terms in following language order: "Russian", "English", "Korean", "German"
    
    When I click the "Source Language" selector
    And I select "German" from the dropdown
    
    Then I should see the Terms in following language order: "German", "Russian", "English", "Korean"
    
    When I click the "Target Language" selector
    And I select "English" from the dropdown
    
    Then I should see the Terms in following language order: "German", "English", "Russian", "Korean"
    
    When I click the "Source Language" selector
    And I select "None" from the dropdown
    
    Then I should see the Terms in following language order: "English", "Russian", "Korean", "German"
    
    When I click the "Source Language" selector
    And I select "French" from the dropdown
    
    Then I should see the Terms in following language order: "French", "English", "Russian", "Korean", "German"
    And I should see "No terms for this language" in the French section
