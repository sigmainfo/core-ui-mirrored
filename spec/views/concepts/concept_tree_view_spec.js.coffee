#= require spec_helper
#= require views/concepts/concept_tree_view
#= require models/concept

describe "Coreon.Views.Concepts.ConceptTreeView", ->

  beforeEach ->
    @model = new Coreon.Models.Concept _id: "123"
    @view = new Coreon.Views.Concepts.ConceptTreeView
      model: @model
    Coreon.application = hits: get: -> undefined

  afterEach ->
    @view.destroy()
    Coreon.application = null

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.Concepts.ConceptTreeView
    
  it "creates container", ->
    @view.$el.should.have.class "concept-tree"

  describe "#render", ->

    beforeEach ->
      sinon.stub I18n, "t"
      sinon.stub Coreon.Models.Concept, "find", (id) ->
        new Coreon.Models.Concept _id: id

    afterEach ->
      I18n.t.restore()
      Coreon.Models.Concept.find.restore()

    it "renders section header", ->
      I18n.t.withArgs("concept.tree").returns "Broader & Narrower"
      @view.render()
      @view.$el.should.have ".section-toggle", text: "Broader & Narrower"

    it "renders listings inside section for toggling", ->
      @view.render()
      @view.$el.should.have ".section"
      @view.$(".section").should.have ".super"
      @view.$(".section").should.have ".self"
      @view.$(".section").should.have ".sub"
  
    it "renders label", ->
      @view.model.label = -> "handgun"
      @view.render()
      @view.$el.should.have ".self"
      @view.$(".self").should.have.text "handgun"

    it "renders superconcepts", ->
      @view.model.set "super_concept_ids", ["71", "75"], silent: true
      @view.render()
      @view.$el.should.have ".super"
      @view.$(".super").find("li .concept-label").length.should.equal 2
      @view.$(".super .concept-label").eq(0).should.have.text "71"
      @view.$(".super .concept-label").eq(1).should.have.text "75"

    it "renders subconcepts", ->
      @view.model.set "sub_concept_ids", ["84", "53", "56"], silent: true
      @view.render()
      @view.$el.should.have ".sub"
      @view.$(".sub").find("li .concept-label").length.should.equal 3
      @view.$(".sub .concept-label").eq(0).should.have.text "84"
      @view.$(".sub .concept-label").eq(1).should.have.text "53"
      @view.$(".sub .concept-label").eq(2).should.have.text "56"

