#= require spec_helper
#= require views/concepts/concept_view
#= require models/concept

describe "Coreon.Views.ConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.ConceptView
      model: new Coreon.Models.Concept
    sinon.stub Coreon.Models.Concept, "find", (id) -> new Coreon.Models.Concept _id: id

  afterEach ->
    I18n.t.restore()
    Coreon.Models.Concept.find.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.match ".concept"

  describe "#initialize", ->
  
    it "creates tree view", ->
      @view.tree.should.be.an.instanceof Coreon.Views.Concepts.ConceptTreeView
      @view.tree.model.should.equal @view.model

    it "creates properties view", ->
      @view.props.should.be.an.instanceof Coreon.Views.Properties.PropertiesView
      @view.props.model.should.equal @view.model

    it "creates terms view", ->
      @view.terms.should.be.an.instanceof Coreon.Views.Terms.TermsView
      @view.terms.model.should.equal @view.model

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
      @view.model.set "super_concept_ids", ["1234"]
      @view.render()
      @view.$el.should.have ".concept-tree"
      @view.$(".concept-tree").should.have ".super"

    it "renders tree only when applicable", ->
      @view.model.set
        sub_concept_ids: []
        super_concept_ids: []
      @view.render()
      @view.$el.should.not.have ".concept-tree"

    it "renders properties", ->
      @view.model.set "properties", [{key: "label", value: "handgun"}], silent: true
      @view.render()
      @view.$el.should.have ".properties"
      @view.$(".properties").should.have ".section table"

    it "renders properties only when applicable", ->
      @view.model.set "properties", [], silent: true
      @view.render()
      @view.$el.should.not.have ".properties"
      

    it "renders terms", ->
      @view.model.set "terms", [
        { lang: "de", value: "Puffe", properties: [] }
      ], silent: true
      @view.render()
      @view.$el.should.have ".terms"
      @view.$(".terms").should.have ".section"
