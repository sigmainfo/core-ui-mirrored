Feature: Maintainer manages connections in concept map
  In order to change a concept's connections to other concepts
  As a maintainer browsing the concept map
  I want to be able to DnD a concept under another concept

  Background:
    Given I am logged in as maintainer of the repository
    And a concept with label "destination of transport" exists
    And the concept "destination of transport" has "intra-EU transport" as a subconcept
    And a concept with label "mode of transport" exists
    And the concept "mode of transport" has "pipeline transport" as a subconcept
    And I visit the repository root page
    And I should see a widget "Concept Map"
    And I click on "Maximize" inside the widget "Concept Map"
   # And I see a concept map inside the main view
    And I click the "Edit mode" button
    And I expanded tree

  @firefox
  Scenario: view the map is frozen when concept map is in edit
    #Then I can move the map with drag and drop on empty space
    And I can zoom in the map
    When I click on the "intra-EU transport" concept node
    #Then I am still in the root node page

  @firefox
  Scenario: additional actions are enabled when concept map is in edit view
    And in this view there is a "Reset" button
    And in this view there is a "Cancel" button
    And in this view there is a "Save relations" button

  @firefox
  Scenario: I can change the superconcept(s) of a concept by dragging it on another one
    Then I drag concept "pipeline transport" on the "destination of transport" concept
#    Then I see concept "pipeline transport" connected with a thick line with concept "destination of transport"
    Then I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"
    When I click "Save relations"
    Then I am in edit mode but save is disabled
    And I see concept "pipeline transport" connected with concept "intra-EU transport"
    And I see concept "intra-EU transport" connected with concept "destination of transport"
    And I see concept "mode of transport" does not heave any subconcepts
#
  @firefox
  Scenario: reset editing of concept map relations
    Then I drag concept "pipeline transport" on the "destination of transport" concept
    #Then I see concept "pipeline transport" connected with a thick line with concept "destination of transport"
    Then I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"
    When I click "Reset"
    Then I am in edit mode
    Then I see concept "destination of transport" connected with concept "intra-EU transport"
    And I see concept "mode of transport" connected with concept "pipeline transport"
    Then I see concept "pipeline transport" has no connection with concept "destination of transport"

  @firefox
  Scenario: cancel editing of concept map relations
    Then I drag concept "pipeline transport" on the "destination of transport" concept
    #Then I see concept "pipeline transport" connected with a thick line with concept "destination of transport"
    Then I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"
    When I click "Cancel"
    Then I am not in edit mode
    Then I see concept "destination of transport" connected with concept "intra-EU transport"
    And I see concept "mode of transport" connected with concept "pipeline transport"
    Then I see concept "pipeline transport" has no connection with concept "destination of transport"








