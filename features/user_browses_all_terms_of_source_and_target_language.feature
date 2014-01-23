Feature: user browses all terms of source and target language
  In order to quickly grasp a translation for a term
  As a user browsing the term sphere
  I want to see terms of source and target language side by side

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: browse target language
    Given a concept with English term "ball" exists
    And this concept has German terms "Ball", "Kugel"
    And a concept with English term "chalk" exists
    And this concept has German term "Kreide"
    And the following English terms exist: "vegetarian", "meal"
    And the following German terms exist: "Asiatisches Essen", "Pilz"
    When I visit the repository root page
    And I select "English" as source language
    When I select "German" as target language
    Then I should see a target language column inside the "Term List"
    And I should see "Ball", "Kugel" as translations for "ball"
    And I should see "Kreide" as translation for "chalk"
    And I should see terms "vegetarian", "meal"
    And they should not have a translation
    And I should not see "Asiatisches Essen", "Pilz"
    When I select "None" as target language
    Then I should not see a target language column anymore
    When I select "German" as source language
    And I select "English" as target language
    Then I should see a target language column inside the "Term List"
    And I should see "Ball", "Kugel" with translation "ball"
    And I should see "Kreide" with translation "chalk"
    And I should see terms "Asiatisches Essen", "Pilz"
    And they should not have a translation
    And I should not see "vegetarian", "meal"

  @wip
  Scenario: render source and target lang in caption
    Given a concept with English term "ball" exists
    And this concept has German terms "Ball", "Kugel"
    When I visit the repository root page
    And I select "English" as source language
    When I select "German" as target language
    Then I should see "Term List (EN, DE)" inside the widget title
    When I select "None" as target language
    Then I should see "Term List (EN)" inside the widget title
    When I select "None" as source language
    Then I should see "Term List" only inside the widget title
