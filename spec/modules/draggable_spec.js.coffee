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
        @draggableOn(@$el, "c0ffee")

    class Coreon.Views.MyView2 extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Draggable
      tagName: "p"
      className: "test-model"
      initialize: ->
        @draggableElement = $('<div class=".element-to-drag">').appendTo(@$el)
        @draggableOn(@draggableElement, "c0ffee")

    @view = new Coreon.Views.MyView
    @view2 = new Coreon.Views.MyView2

    @dragStartEvent = jQuery.Event "dragstart", target: @view.$el[0]
    @dragStopEvent  = jQuery.Event "dragstop",  target: @view.$el[0]

  it "makes $el draggable", ->
    @view.$el.data("uiDraggable").should.exist

  it "adds drag ghost to modal layer", ->
    options = @view.$el.data("uiDraggable").options
    options.appendTo.should.equal "#coreon-modal"

  it "adds class to dragged source element", ->
    @view._draggable_startDragging(@dragStartEvent)
    @view.$el.should.have.class "ui-draggable-dragged"

  it "adds class to dragged source element", ->
    @view._draggable_stopDragging(@dragStopEvent)
    @view.$el.should.not.have.class "ui-draggable-dragged"

  it "uses alternative drag element", ->
    should.not.exist @view2.$el.data("uiDraggable")
    @view2.draggableElement.data("uiDraggable").should.exist

