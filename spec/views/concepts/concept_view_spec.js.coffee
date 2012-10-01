#= require spec_helper
#= require views/concepts/concept_view
#= require models/concept

describe "Coreon.Views.ConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.ConceptView
      model: new Coreon.Models.Concept

  afterEach ->
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.match ".concept"

  describe "#initialize", ->
  
    it "creates tree view", ->
      @view.initialize()
      @view.tree.should.be.an.instanceof Coreon.Views.Concepts.ConceptTreeView
      @view.tree.model.should.equal @view.model

  describe "#render", ->

    it "can be chained", ->
      @view.render().should.equal @view
  
    it "renders label", ->
      @view.model.label = -> "Handgun"
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$("h2.label").should.have.text "Handgun"

    it "renders id", ->
      I18n.t.withArgs("concepts.concept.id").returns "ID"
      I18n.t.withArgs("concepts.concept.values.id", id: "1234").returns "#1234"
      @view.model.id = "1234"
      @view.render()
      @view.$el.should.have "h3.id"
      @view.$("h3.id").text().should.match /^\s*ID\s+#1234\s*$/

    it "renders tree", ->
      @view.render()
      @view.$el.should.have ".concept-tree"
      @view.$(".concept-tree").should.have ".super"

