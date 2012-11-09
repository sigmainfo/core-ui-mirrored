#= require spec_helper
#= require views/concepts/concept_list_view
#= require views/composite_view

describe "Coreon.Views.Concepts.ConceptListView", ->
  
  beforeEach ->
    sinon.spy Coreon.Models.Concept, "upsert"
    sinon.stub Coreon.Models.Concept, "find"
    @view = new Coreon.Views.Concepts.ConceptListView
      model: new Backbone.Model(hits: [])
      collection: new Backbone.Collection

  afterEach ->
    @view.destroy()
    Coreon.Models.Concept.find.restore()
    Coreon.Models.Concept.upsert.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "renders container", ->
    @view.$el.should.match "div.concept-list"

  describe "#render", ->
    
    it "can be chained", ->
      @view.render().should.equal @view

    it "renders list items", ->
      concept = _(new Backbone.Model).extend label: -> "A Concept"
      concept2 = _(new Backbone.Model).extend label: -> "Another Concept"
      Coreon.Models.Concept.find.withArgs("50506ebdd19879161b000019").returns concept
      Coreon.Models.Concept.find.withArgs("50506ebdd19879161b000015").returns concept2
      @view.model.set
        hits: [
          {
            score: 1.567
            result:
              _id: "50506ebdd19879161b000019"
          }
          {
            score: 0.431
            result:
              _id: "50506ebdd19879161b000015"
          }
        ], {silent: true}
      @view.render()
      @view.subviews.length.should.equal 2
      @view.subviews[0].should.be.an.instanceof Coreon.Views.Concepts.ConceptListItemView
      @view.subviews[0].model.should.equal concept
      @view.$el.should.have ".concept-list-item"
      @view.$(".concept-list-item").eq(0).should.have ".concept-label"
      Coreon.Models.Concept.upsert.should.have.been.calledWith _id: "50506ebdd19879161b000019"

    it "is triggered by model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce