#= require spec_helper
#= require views/concepts/concept_list_item_view

describe "Coreon.Views.Concepts.ConceptViewItemView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Concepts.ConceptListItemView
      model: _(new Backbone.Model).extend
        label: -> "Concept123"

  it "is a Coreon view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.class "concept-list-item"

  describe "#render", ->

    it "renders label", ->
      @view.model.label = -> "My Concept"
      @view.render()
      @view.$el.should.have ".concept-label"
      @view.$(".concept-label").should.have.text "My Concept"

    it "renders id", ->
      @view.model.id = "1234"
      @view.render()
      @view.$el.should.have ".concept-id"
      @view.$(".concept-id").should.have.text "1234"

    it "destroys previously created subviews", ->
      @view.render()
      label = @view.subviews[0]
      label.destroy = sinon.spy()
      @view.render()
      label.destroy.should.have.been.calledOnce
