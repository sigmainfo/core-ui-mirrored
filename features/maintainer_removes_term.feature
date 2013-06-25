Feature: maintainer removes term
  In order to make a term no longer available
  As a maintainer editing data in the repository
  I want to remove an existing term from a concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    And a concept with an English term "beaver hat" exists
    And I am a maintainer of the repository
    And I visit the page of this concept

  Scenario: remove term
    When I click "Edit concept" 
    And I click "Remove term" within term "beaver hat"
    Then I should see a confirmation dialog "This term will be deleted permanently."
    When I click outside the dialog
    Then I should not see a confirmation dialog
    And I should still see the English term "beaver hat"
    When I click "Remove term" within term "beaver hat"
    And I click "OK" within the dialog
    Then I should see a message 'Successfully deleted term "beaver hat".'
    And I should not see a confirmation dialog
    And I should not see "beaver hat"
