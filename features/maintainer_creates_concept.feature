@wip
Feature: maintainer creates concept
  In order to create a new concept
  As a maintainer that searches for a non-existing concept
  I want to create a new concept and its properties and terms

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in

  Scenario: create concept
    When I enter "gun" in the search field
    And I click the search button
    Then I should see a button "Create Concept"
    When I click on the create concept link
    Then I should be on the create concept page
    And I should see title "<New Concept>"
    #And I should see the "Broader and Narrower" section with only "gun"?
    And I should see an "Add Property" link
    And I should see an "Add Term" link
    And I should see a link to "create" the concept
    And I should see a link to "cancel" the creation of the concept
    When I click on "Add Term"
    Then I should see two empty inputs for Term Value and Language
    And I should see a "Remove Term" link for the new term
    When I click on "Create"
    Then I should see a concept error message "Concept could not be saved" with "Terms had errors"
    Then I should see term error messages "Please enter a Term Value" and "Please enter the Language of the Term"
    When I click on "Remove Term"
    Then I should not see the term inputs anymore 
    When I click on "Add Property" link 
    Then I should see inputs for Property Key, Value and Language
    When I click on "Create"
    Then I should see a concept error message "Concept could not be saved" with "Properties had errors"
    Then I should see property error messages "Please enter a Property Key" and "Please enter a Property Value"
    When I click on the "Remove Property"
    Then I should not see the property input anymore
    When I click on "Add Term"
    And I click on "Add Property" link 
    And I enter "flower" as Term Value and "en" as Term Language
    And I enter "label" as Property Key and "flowerpower" as Property Value
    And I click on "Create"
    Then I should be redirected to the concept page of the newly created concept
    When I enter "flower" in the search field
    And I click the search button
    Then I should see a concept "flowerpower"

  Scenario: cancel create concept
    When I enter "gun" in the search field
    And I click the search button
    And I click on the create concept link
    Then I should be on the create concept page
    When I click on the "Cancel" link
    Then I should see the search result page again
