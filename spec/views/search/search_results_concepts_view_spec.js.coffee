#= require spec_helper
#= require views/search/search_results_concepts_view
#= require config/application

describe "Coreon.Views.Search.SearchResultsConceptsView", ->
  
  beforeEach ->
    Coreon.application = new Coreon.Application
    Coreon.application.sync = sinon.spy()
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Search.SearchResultsConceptsView model: new Backbone.Model(hits: [])
    @view.model.query = -> "q=foo"

  afterEach ->
    Coreon.application.destroy()
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.class "search-results-concepts"

  describe "#render", ->

    it "is chainable", ->
      @view.render().should.equal @view
    
    it "renders headline", ->
      I18n.t.withArgs("search.results.concepts.headline").returns "Concepts"
      @view.render()
      @view.$el.should.have "h3"
      @view.$("h3").should.have.text "Concepts"

    it "renders table header", ->
      I18n.t.withArgs("search.results.concepts.header.label").returns "Label"
      I18n.t.withArgs("search.results.concepts.header.super_concepts").returns "Superconcepts"
      I18n.t.withArgs("search.results.concepts.header.id").returns "ID"
      @view.render()
      @view.$el.should.have "table.concepts"
      @view.$(".concepts th").eq(0).should.have.text "Label"
      @view.$(".concepts th").eq(1).should.have.text "Superconcepts"
      @view.$(".concepts th").eq(2).should.have.text "ID"

    it "renders concepts", ->
      @view.model.set "hits", [
        result:
          _id: "503e248cd198795712000005"
          properties: [
            key: "label"
            value: "poet"
          ]
          super_concept_ids: [
            "503e248cd198795712000002"
            "504e248cd198795712000042"
          ]
      ]
      @view.render()
      @view.$(".concepts tbody tr:first td.label").should.have "a[href='/concepts/503e248cd198795712000005']"
      @view.$("a[href='/concepts/503e248cd198795712000005']").should.have.text "503e248cd198795712000005"

      @view.$(".concepts tbody tr:first td.super").should.have "a.concept-label[href='/concepts/503e248cd198795712000002']"
      @view.$(".concepts tbody tr:first td.super").should.have "a.concept-label[href='/concepts/504e248cd198795712000042']"

      @view.$(".concepts tbody tr:first td.id").should.have.text "503e248cd198795712000005"

    it "renders top 10 concepts only", ->
      @view.model.set "hits",
        for n in [1..25]
          result:
            _id: "503e248cd198795712000005"
            properties: [
              key: "label"
              value: "poet"
            ]
            super_concept_ids: []
      @view.render()
      @view.$("tbody tr").length.should.equal 10

    it "is triggered on model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

    it "renders link to complete list", ->
      I18n.t.withArgs("search.results.concepts.show_all").returns "Show all"
      @view.model.query = -> "q=gun"
      @view.render()
      @view.$el.should.have "a.show-all[href='/concepts/search?q=gun']"
      @view.$("a.show-all").should.have.text "Show all"
