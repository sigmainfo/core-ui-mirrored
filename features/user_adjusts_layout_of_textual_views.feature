Feature: user adjusts layout of textual views
  In order to make everything accessible all the time
  As a user adjusting the width of the widgets column
  I want to see all information including edit functionality all the time

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And I am logged in

  Scenario: drag to resize
    Given the widgets column has a width of 300px
    When I visit the repository root page
    And I drag the resize handle of the concept map to the left by 200px
    Then I should still be able to click the "NEW CONCEPT" button
