Feature: user searches in source and target language
  In order to get a list of relevant concepts and terms
  As a user that searches for a specific information in specific languages
  I want to enter a query string and trigger a search

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  # Scenario: trigger search
  #   Given the languages "English", "German", and "French" are available
  #   And a concept defined as "A portable firearm"
  #   And this concept has the English term "gun"
  #   And this concept has the German term "Schusswaffe"
  #   And this concept has the French term "arme à feu"
  #   And this concept hat the Russian term "пистолет"
  # 
  #   
  #   When I click the "Source Language" selector
  #   And I select "None" from the dropdown
  #   And I click the "Target Language" selector
  #   And I select "None" from the dropdown
  #   
  #   And I enter "пистолет" in the search field
  #   And I click the search button
  #   
  #   Then I should see 1 term hit
  #   #And I should see 1 concept hit
  #   
  #   When I click the "Source Language" selector
  #   And I select "German" from the dropdown
  #   And I click the "Target Language" selector
  #   And I select "French" from the dropdown
  #   
  #   And I click the search button
  #   
  #   Then I should see no term hit
  #   #And I should see no concept hit
  #   
  #   And I enter "Schusswaffe" in the search field
  #   And I click the search button
  #   
  #   Then I should see 1 term hit
  #   #And I should see 1 concept hit
  #   
  #   When I click the "Source Language" selector
  #   And I select "English" from the dropdown
  #   And I click the search button
  #   
  #   Then I should see no term hit
  #   #And I should see no concept hit
  #   