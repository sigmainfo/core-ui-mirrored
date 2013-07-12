Feature: maintainer edits term
  In order to update data connected to a term
  As a maintainer editing data in the repository
  I want to edit an existing term

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    And a concept with an English term "ten-gallon hat" exists

  Scenario: edit term
    Given I have maintainer privileges
    And I am on the show concept page of this concept
    When I click "Edit concept" 
    When I click "Edit term" within term "ten-gallon hat"
    Then I should see a set of term inputs with labels "Value", "Language"
    And I should see "ten-gallon hat" for input "Value"
    And I should see "en" for input "Language"
    When I fill in "Value" with "Cowboyhut" within term inputs
    And I fill in "Language" with "de" within term inputs
    And I click "Add property" within term inputs
    Then I should see a set of property inputs with labels "Key", "Value", "Language"
    When I fill in "Key" with "status" within property inputs
    And I fill in "Value" with "pending" within property inputs
    When I click "Save term"
    Then I should see a term "Cowboyhut" within language "DE"
    When I click "PROPERTIES" within term
    Then I should see a property "STATUS" for the term with value "pending"
    And I should see a message 'Successfully saved term "Cowboyhut".'
    And I should see "Cowboyhut" within the title
    But I should not see "Save term"

  Scenario: removing existing properties
    Given this term has a property "notice" of "TODO: translate"
    And I have maintainer privileges
    And I am on the show concept page of this concept
    When I click "Edit concept" 
    When I click "Edit term" within term "ten-gallon hat"
    Then I should see a set of property inputs with labels "Key", "Value", "Language"
    And I should see "notice" for property input "Key"
    And I should see "TODO: translate" for property input "Value"
    When I click "Remove property"
    Then the property inputs should be disabled
    When I click "Save term"
    Then I should see a confirmation dialog warning that one property will be deleted
    When I click "OK" within the dialog
    Then I should see a message 'Successfully saved term "ten-gallon hat".'
    And I should see a term "ten-gallon hat" within language "EN"
    But I should not see "PROPERTIES" within that term

  Scenario: validation errors
    Given I have maintainer privileges
    And I am on the show concept page of this concept
    When I click "Edit concept"
    When I click "Edit term"
    Given client-side validation is turned off
    When I fill in "Value" with "Stetson" within term inputs
    When I fill in "Language" with "" within term inputs
    And I click "Add property" within term inputs
    And I fill in "Key" with "" within property inputs
    And I click "Save term"
    Then I should see an error summary
    And this summary should contain "Failed to save term:"
    And this summary should contain "1 error on lang"
    And this summary should contain "2 errors on properties"
    And I should see error "can't be blank" for term input "Language"
    And I should see error "can't be blank" for property input "Key" within term inputs
    When I click "Remove property"
    And I fill in "Language" with "en" within term inputs
    And I click "Save term"
    Then I should see a term "Stetson" within language "EN"
    And I should not see an error summary
    But I should see a message 'Successfully saved term "Stetson".'

  Scenario: reset and cancel
    Given this term has a property "notice" of "TODO: translate"
    And I have maintainer privileges
    And I am on the show concept page of this concept
    When I click "Edit concept" 
    When I click "Edit term"
    And I fill in "Value" with "high hat" within term inputs
    And I click "Remove property"
    And I click "Add property" within term inputs
    And I fill in "Key" with "status" within property inputs
    And I fill in "Value" with "pending" within property inputs
    When I click "Reset"
    Then I should see "ten-gallon hat" for input "Value"
    And I should see exactly one set of property inputs
    And I should see "notice" for property input "Key"
    And I should see "TODO: translate" for property input "Value"
    And I should see "Save term"
    And I fill in "Value" with "high hat" within term inputs
    And I click "Remove property"
    And I click "Cancel"
    Then I should not see "Save term"
    And I should not see "high hat"
    When I click "Edit term"
    Then I should see "ten-gallon hat" for input "Value"
    And I should see exactly one set of property inputs
    And I should see "notice" for property input "Key"
    And I should see "TODO: translate" for property input "Value"
    And I should see "Save term"

