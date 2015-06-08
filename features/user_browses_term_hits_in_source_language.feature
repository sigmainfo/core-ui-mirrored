Feature: User browses term hits in source language
  In order to quickly browse current terms in source language
  As a user exploring a selection of concepts
  I want to see an alphabetic listing of all relevant terms

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And the languages "English", "German", and "French" are available
    And I am logged in

  Scenario: terms for current hits
    Given a concept with English term "billiards" exists
    And this concept has a German term "Billiard"
    And a concept with English term "billiards table" exists
    And this concept has a German term "Billiardtisch"
    And a concept with English term "billiard ball" exists
    And this concept has German terms "Billiardkugel" and "Ball"
    And a concept with English term "8-ball" exists
    And this concept has a German term "8er-Ball"
    And a concept with English term "high bridge" exists
    And this concept has a German term "Brücke über einen Ball"
    When I do a search for "ball"
    And I select "English" as source language
    Then the "Term List" widget should contain 6 items
    When I select "German" as source language
    Then the "Term List" widget should contain 7 items
    When I click the first item
    Then I should be on the concept details page for "8-ball"
