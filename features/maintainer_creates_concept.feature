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
    And I click on the create concept link
    Then I should be on the create concept page for "gun"
    And I should see title "gun"
    And I should see an "Add Property" link
    And I should see an "Add Term" link
    And I should see a link to "create" the concept
    And I should see a link to "cancel" the creation of the concept
    And I should see an input for term value with "gun"
    And I should see an input "language" filled with the users search language
    And I should see a "Remove Term" link
    #And I should see the "Broader and Narrower" section with only "gun"?
    And I should see an "Add Property" link for the term
    When I enter "flower" into the term value field
    Then I should see title "flower"
    When I click on "Add Term"
    Then I should see two new empty inputs for Term Value and Language
    #And the input for Term Value should be selected
    And I should see a "Remove Term" link for the new term
    When I click on "Remove Term"
    Then I should not see the term inputs anymore 
    When I click on "Add Property" link 
    Then I should see inputs for Property Key, Value and Language
    When I enter "label" as Property Key and "flowerpower" as Property Value
    Then I should see title "flowerpower"


    When I click on "Add Term"
    #HERE -> And I enter "Waffe" into the new Term Value input field
    And I click on "Add Property"
    Then I should see two new empty inputs for Property Key and Property Value
    And the input for Property Key should be selected
    And there is a Cancel link attached to the inputs
    When I click on "Cancel"
    Then I should not see the property inputs anymore 
    When I fill in "something to kill with" into the new Property Value field
    And I click on the "create" link
    Then i should see error "Can't be blank" on term language
    And i should see error "Can't be blank" on property key
    When I fill in "DE" as language of the new term
    And I fill in "description" as property key of the new property 
    And I click on the "create" link
    Then I should see the show concept page
    And the concept should have title "gun"
    And it should have german term "Waffe" and english term "gun"
    And it should have property "description" with value "something to kill with"

#  Scenario: cancel create concept
#    When I enter "gun" in the search field
#    And I click the search button
#    And I click on the create concept link
#    Then I should be on the create concept page
#    And I click on the "cancel" link
#    Then I should see the empty search result page again
