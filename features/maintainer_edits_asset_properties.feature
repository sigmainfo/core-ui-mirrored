Feature: maintainer edits asset properties
  In order to better describe a concept or a term
  As a maintainer editing the details of a single concept/term
  I want to be able to add/remove a list of asset properties for the concept and for each term

  Background:
    Given I am logged in as maintainer of the repository

  Scenario: add required asset property to new concept
    Given the repository defines a blueprint for concepts
    And that blueprint defines a required property "image" of type "asset"
    When I visit the repository root page
    And I click on "New concept"
    Then I see a section "PROPERTIES" within the form "Create concept"
    And I see a fieldset "IMAGE" within this section
    And this fieldset contains a text input titled "CAPTION"
    And this fieldset contains a file input
    And this fieldset contains a select "LANGUAGE"
    When I fill in "CAPTION" with "Crane photo"
    When I select file "LTM1750.jpg" for the file input
    Then I see a preview thumbnail of the image
    And I select "English" for "LANGUAGE"
    And I click "Create concept"
    Then I look at the properties inside the concept header
    And I see a property "IMAGE"
    And there is a thumbnail captioned "Crane photo"

  Scenario: add required asset property to new concept's term
    Given the repository defines a blueprint for concepts
    Given the repository defines a blueprint for terms
    And that blueprint defines a required property "image" of type "asset"
    When I visit the repository root page
    And I click on "New concept"
    And I click "Add term"
    Then I see a section "PROPERTIES" under "TERMS" within the form "Create concept"
    When I fill in "Crane" for "VALUE"
    And I fill in "en" for "LANGUAGE"
    And I see a fieldset "IMAGE" within this section
    And this fieldset contains a text input titled "CAPTION"
    And this fieldset contains a file input
    And this fieldset contains a select "LANGUAGE"
    When I fill in "CAPTION" with "Crane photo"
    When I select file "LTM1750.jpg" for the file input
    Then I see a preview thumbnail of the image
    And I select "English" for "LANGUAGE"
    And I click "Create concept"
    Then I see term "Crane" within language section "EN"
    When I toggle "Properties" within this term
    Then I see a property "IMAGE"
    And there is a thumbnail captioned "Crane photo"

  Scenario: add required asset property to concept's new term
    Given the repository defines a blueprint for terms
    And that blueprint defines a required property "image" of type "asset"
    And a concept "Crane" exists
    When I edit that concept
    And I click "Add term"
    Then I see a section "PROPERTIES" under "TERMS" within the form "Create term"
    When I fill in "Crane" for "VALUE"
    And I fill in "en" for "LANGUAGE"
    And I see a fieldset "IMAGE" within this section
    And this fieldset contains a text input titled "CAPTION"
    And this fieldset contains a file input
    And this fieldset contains a select "LANGUAGE"
    When I fill in "CAPTION" with "Crane photo"
    When I select file "LTM1750.jpg" for the file input
    Then I see a preview thumbnail of the image
    And I select "English" for "LANGUAGE"
    And I click "Create term"
    Then I see term "Crane" within language section "EN"
    When I toggle "Properties" within this term
    Then I see a property "IMAGE"
    And there is a thumbnail captioned "Crane photo"

  Scenario: add optional asset property to existing term
    Given the repository defines a blueprint for terms
    And that blueprint defines a property "image" of type "asset"
    And a concept with the english term "Crane" exists
    And that term has a property "image" with caption "Crane photo"
    When I edit that concept
    And I click "Edit term" within the term "Crane"
    Then I see a section "PROPERTIES" within the form "Save term"
    And I see a fieldset "IMAGE" within this form
    And this fieldset contains an image captioned "Crane photo"
    Then I click on "Add another image" inside "IMAGE"
    And I fill in "CAPTION" with "Front view"
    And I select file "front_view.jpg" for the file input
    And I click "Save term"
    Then I see term "Crane" within language section "EN"
    When I toggle "Properties" within this term
    Then I see a property "IMAGE"
    And there is a thumbnail captioned "Crane photo"
    And there is a thumbnail captioned "Front view"

  Scenario: delete optional concept's asset property
    Given the repository defines a blueprint for concepts
    And that blueprint defines a property "image" of type "asset"
    And a concept "Crane" exists
    And that concept has a property "image" with caption "Crane photo"
    When I edit that concept
    Then I see a section "PROPERTIES"
    When I click on "Edit properties"
    Then I see a form "Save concept"
    And I see a fieldset "IMAGE" within this form
    And this fieldset contains an image captioned "Crane photo"
    When I click on "Remove image" within "IMAGE"
    And I click "Save concept"
    Then I see a confirmation dialog
    Then I click "OK" on the confirmation dialog
    Then I look at the properties inside the concept header
    But I do not see "IMAGE"

  Scenario: delete optional concept's asset property
    Given the repository defines a blueprint for terms
    And that blueprint defines a property "image" of type "asset"
    And that blueprint defines a property "description" of type "text"
    And a concept with the english term "Crane" exists
    And that term has a property "image" with caption "Crane photo"
    And that term has a property "description" with caption "Crane"
    When I edit that concept
    And I click "Edit term" within the term "Crane"
    Then I see a section "PROPERTIES" within the form "Save term"
    And I see a fieldset "IMAGE" within this form
    When I click on "Remove image" within "IMAGE"
    And I click "Save term"
    Then I see a confirmation dialog
    Then I click "OK" on the confirmation dialog
    Then I see term "Crane" within language section "EN"
    When I toggle "Properties" within this term
    But I do not see "IMAGE"
