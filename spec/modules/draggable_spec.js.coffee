#= require spec_helper
#= require jquery.ui.draggable
#= require modules/helpers
#= require modules/draggable

describe "Coreon.Modules.Draggable", ->

  before ->
    class Coreon.Views.MyView extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Draggable
      tagName: "p"
      className: "test-model"
      initialize: ->
        @draggableOn()

    class Coreon.Views.MyView2 extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Draggable
      tagName: "p"
      className: "test-model"
      initialize: ->
        @draggableElement = $('<div class=".element-to-drag">').appendTo(@$el)
        @draggableOn()

    @view = new Coreon.Views.MyView
    @view2 = new Coreon.Views.MyView2

  it "makes $el draggable", ->
    @view.$el.data("uiDraggable").should.exist

  it "adds drag ghost to modal layer", ->
    options = @view.$el.data("uiDraggable").options
    options.appendTo.should.equal "#coreon-modal"

  it "adds class to dragged source element", ->
    @view._draggable_startDragging()
    @view.$el.should.have.class "ui-draggable-dragged"

  it "adds class to dragged source element", ->
    @view._draggable_stopDragging()
    @view.$el.should.not.have.class "ui-draggable-dragged"

  it "uses alternative drag element", ->
    console.log @view2.draggableElement
    should.not.exist @view2.$el.data("uiDraggable")
    @view2.draggableElement.data("uiDraggable").should.exist


