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

  #TODO: test render on change

  describe "#render", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "is triggered by model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce
  
    it "renders label", ->
      @view.model.label = -> "Handgun"
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$("h2.label").should.have.text "Handgun"

    it "renders system info", ->
      I18n.t.withArgs("concept.info").returns "System Info"
      @view.model.id = "123"
      @view.model.set "legacy_id", "543", silent: true
      @view.render()
      @view.$el.should.have "> .system-info-toggle"
      @view.$("> .system-info-toggle").should.have.text "System Info"
      @view.$el.should.have "> .system-info"
      @view.$("> .system-info").css("display").should.equal "none"
      @view.$("> .system-info th").eq(0).should.have.text "id"
      @view.$("> .system-info td").eq(0).should.have.text "123"
      @view.$("> .system-info th").eq(1).should.have.text "legacy_id"
      @view.$("> .system-info td").eq(1).should.have.text "543"

    it "renders tree", ->
      @view.model.set "super_concept_ids", ["1234"]
      @view.render()
      @view.$el.should.have ".concept-tree"
      @view.$(".concept-tree").should.have ".super"
      #TODO: test for correct model/data

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
      #TODO: test for correct model/data

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
      #TODO: test for correct model/data

    #TODO: test render terms only when applicable 

  describe "#toggleInfo", ->

    beforeEach ->
      @view.render()
  
    it "is triggered by click on system info toggle", ->
      @view.toggleInfo = sinon.spy()
      @view.delegateEvents()
      @view.$(".system-info-toggle").click()
      @view.toggleInfo.should.have.been.calledOnce

    it "toggles system info", ->
      $("#konacha").append(@view.$el)
      @view.$(".system-info").should.be.hidden
      @view.toggleInfo()
      @view.$(".system-info").should.be.visible
      @view.toggleInfo()
      @view.$(".system-info").should.be.hidden
    
