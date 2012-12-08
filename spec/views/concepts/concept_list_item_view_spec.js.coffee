#= require spec_helper
#= require views/concepts/concept_list_item_view

describe "Coreon.Views.Concepts.ConceptListItemView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Concepts.ConceptListItemView
      model: _(new Backbone.Model terms: []).extend
        label: -> "Concept123"

  it "is a Coreon view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.match "tbody.concept-list-item"

  describe "#render", ->

    it "renders label", ->
      @view.model.label = -> "My Concept"
      @view.render()
      @view.$el.should.have ".concept-label"
      @view.$(".concept-label").should.have.text "My Concept"

    it "renders definition", ->
      @view.model.set "properties", [
        key: "definition"
        value: "He Who Talks Loud, Saying Nothing."
      ]
      @view.render()
      @view.$el.should.have ".definition"
      @view.$(".definition td").should.have.text "He Who Talks Loud, Saying Nothing."
