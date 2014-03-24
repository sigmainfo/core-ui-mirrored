Feature: user adjusts layout
  In order to make best use of the screen real estate
  As a user working with different views simultaneously
  I want to adjust the size of a widget

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: drag to resize
    Given the widgets column has a width of 300px
    And the concept map widget has a height of 240px
    When I drag the resize handle of the concept map to the left by 150px
    Then I should see the widgets column being 450px wide
    And I should see the concept map widget keeping its height of 240px
    When I drag the bottom resize handler of the concept map widget down by 50px
    Then I should see the concept map widget being 290px high
    When I drag the bottom resize handler of the concept map widget up by 230px
    Then I should see the concept map widget having its minimal height of 80px
    When I drag the resize handle of the widgets column to the right by 400px
    Then I should see the widgets column having a minimal width of 240px
