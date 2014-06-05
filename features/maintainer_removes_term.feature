Feature: maintainer removes term
  In order to cleanup deprecated information
  As a maintainer editing a concept
  I want to permanently delete an existing term

  Background:
    Given I am logged in as maintainer of the repository

  Scenario: delete term
    Given a concept with an English term "beaver hat" exists
    When I edit this concept
    Then I see a term "beaver hat"
    When I click "Remove term" inside of it
    Then I see a confirmation dialog
    When I click to confirm
    Then I do not see the confirmation dialog anymore
    And I do not see the term "beaver hat" anymore
    But I see a message 'Successfully deleted term "beaver hat"'

  Scenario: cancel deletion
    Given a concept with an English term "beaver hat" exists
    When I edit this concept
    Then I see a term "beaver hat"
    When I click "Remove term" inside of it
    Then I see a confirmation dialog
    When I click to cancel
    Then I do not see the confirmation dialog anymore
    But I still see the term "beaver hat"
