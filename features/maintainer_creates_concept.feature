@wip
Feature: maintainer creates concept
  In order to make information available in context of a not yet existent concept
  As a maintainer that is adding data to the repository
  I want to create a new concept optionally populated with some initial terms or properties

  Background:
    Given my name is "William Blake" with login "Nobody" and password "se7en!"
    And I am logged in
  
  Scenario: create empty concept
    Given I have maintainer privileges
    When I visit the start page
    And I click on "New concept"
    Then I should be on the new concept page
    And I should see "<New concept>" within the title
    And I should see a new concept node "<New concept>" within the concept map
    And I should see a section "Broader & Narrower"
    And I should see "<New concept>" being the current selection
    And I should see "Repository" within the list of broader concepts
    When I click "Create concept"
    Then I should be on the show concept page
    And I should see the id of the newly created concept within the title
    And I should see a new concept node with the id of the newly created concept within the concept map
    And I should see this node being a child of the repository root node
    And I should see a section "Broader & Narrower"
    And I should see the id of the newly created concept being the current selection
    And I should see "Repository" within the list of broader concepts

  # Scenario: add property
  #   Given I have maintainer privileges
  #   When I visit the start page
  #   And I click on "New concept"
  #   And I click "Add property"
  #   Then I should see a set of property inputs with labels "Key", "Value", "Language"
  #   When I click "Remove property" within the set
  #   Then I should not see a set of property inputs anymore
  #   When I click "Add property"
  #   And I fill "Key" with "label"
  #   And I fill "Value" with "dead man"
  #   And I click "Create concept"
  #   Then I should see "dead man" within the title
  #   And I should see a property "label" with value "dead man"

  # Scenario: add term
  #   Given I have maintainer privileges
  #   When I visit the start page
  #   And I click on "New concept"
  #   And I click "Add term"
  #   Then I should see a set of term inputs with labels "Value", "Language"
  #   When I click "Remove term" within the set
  #   Then I should not see a set of term inputs anymore
  #   When I click "Add term"
  #   And I fill "Value" with "corpse"
  #   And I fill "Language" with "en"
  #   And I click "Create concept"
  #   Then I should see "corpse" within the title
  #   And I should see an English term "corpse"

  # Scenario: validation errors
  #   Given I have maintainer privileges
  #   When I visit the start page
  #   And I click on "New concept"
  #   And I click "Add property"
  #   And I click "Add term"
  #   And I fill "Value" of term with "corpse"
  #   And I click "Create concept"
  #   Then I should see an error summary
  #   And this summary should contain "Concept could not be created:"
  #   And this summary should contain "2 errors on properties"
  #   And this summary should contain "1 error on terms"
  #   And I should see error "can't be blank" for property input "Key"
  #   And I should see error "can't be blank" for property input "Value"
  #   And I should see error "can't be blank" for term input "Language"
  #   When I click "Remove property"
  #   And I fill "Language" of term with "en"
  #   And I click "Create concept"
  #   Then I should be on the new concept page
  #   And I should not see an error summary
  #   But I should see message 'Successfully created concept "corpse".'

  # Scenario: cancel creation
  #   Given I have maintainer privileges
  #   When I visit the start page
  #   And I click on "New concept"
  #   When I click "Cancel"
  #   Then I should be on the start page again
  #   And I should not see "<New concept>"
  #   But I should see "New concept"
  
  # Scenario: term from recent search
  #   Given I have maintainer privileges
  #   When I do a search for "corpse"
  #   And I click on "New concept"
  #   Then I should be on the new concept page
  #   And I should see "<New concept>" within the title
  #   And I should see a set of term inputs
  #   And I should see "corpse" for "Value"
  #   And I should see "en" for "Language"

  # Scenario: not a maintainer
  #   Given I do not have maintainer privileges
  #   When I visit the start page
  #   Then I should not see "New concept"
  #   When I do a search for "corpse"
  #   Then I should not see "New concept"
  #   When I visit "/concepts/new"
  #   Then I should be on the previous page
  #   And I should not see a "Create concept" button
