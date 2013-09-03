#= require spec_helper
#= require jquery.ui.droppable
#= require modules/helpers
#= require modules/droppable

describe "Coreon.Modules.Droppable", ->

  before ->
    class Coreon.Views.MyView extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Droppable
      tagName: "p"
      className: "test-model"
      initialize: ->
        @droppableOn(@$el, "c0ffee")

  beforeEach ->
    @view = new Coreon.Views.MyView


  it "makes $el droppable", ->
    @view.$el.data("uiDroppable").should.exist

  it "turns off droppable", ->
    @view.droppableOff @view.$el
    @view.$el.data("uiDroppable").options.disabled.should.be.true

  it "overwrites default options", ->
    @view.$el.data("uiDroppable").options.tolerance.should.equal "pointer"
    @view.droppableOff @view.$el
    @view.droppableOn @view.$el, "c0ffee", tolerance: "fancy"
    @view.$el.data("uiDroppable").options.tolerance.should.equal "fancy"

  xit "adds class to draggable on hover"
    # don't know how to test this…
  
  it "re-enables drops after disable", ->
    @view.droppableOff @view.$el
    @view.droppableOn @view.$el, "c0ffee"
    @view.$el.data("uiDroppable").options.disabled.should.be.false
