#= require spec_helper
#= require views/concepts/new_concept_view

describe "Coreon.Views.Concepts.NewConceptView", ->

  beforeEach ->
    @view = new Coreon.Views.Concepts.NewConceptView
      model: new Backbone.Model

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "is classified as new concept", ->
    @view.$el.should.have.class "concept"
    @view.$el.should.have.class "new"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view
  
    it "renders caption", ->
      @view.model.set "label", "<New concept>", silent: true
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$("h2.label").should.have.text "<New concept>"
