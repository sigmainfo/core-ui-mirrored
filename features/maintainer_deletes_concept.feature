Feature: maintainer deletes concept
  In order to make a concept no longer available
  As a maintainer editing data in the repository
  I want to remove an existing concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And I am logged in
    And a concept with an English term "beaver hat" exists

  Scenario: delete concept
    Given I am on the show concept page of "beaver hat"
    When I click "Edit concept"
    And I click "Delete concept"
    Then I should see a confirmation dialog "This concept including all terms will be deleted permanently."
    When I click outside the dialog
    Then I should not see a confirmation dialog
    And I should still be on the show concept page
    When I click "Delete concept"
    And I click "OK" within the dialog
    Then I should be on the repository root page
    And I should not see a confirmation dialog
    And I should see a message 'Successfully deleted concept "beaver hat".'
    When I search for "hat"
    Then I should not see "beaver hat"

  Scenario: delete subconcept
    Given "beaver hat" is a subconcept of "hat"
    And I am on the show concept page of "beaver hat"
    When I click "Edit concept"
    And I click "Delete concept"
    And I click "OK" within the dialog
    Then I should be on the repository root page
    When I navigate to the show concept of "hat"
    Then I should see no narrower concepts for "hat"
