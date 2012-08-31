#= require spec_helper
#= require views/main/search_results_terms_view

describe "Coreon.Views.Main.SearchResultsTermsView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Main.SearchResultsTermsView model: new Backbone.Model
    @view.model.set "hits", []

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.have.class "search-results-terms"

  describe "#render", ->

    it "is chainable", ->
      @view.render().should.equal @view
    
    it "renders headline", ->
      I18n.t.withArgs("search.results.terms.headline").returns "Terms"
      @view.render()
      @view.$el.should.have "h3"
      @view.$("h3").should.have.text "Terms"

    it "renders table header", ->
      I18n.t.withArgs("search.results.terms.header.term").returns "Term"
      I18n.t.withArgs("search.results.terms.header.language").returns "Language"
      I18n.t.withArgs("search.results.terms.header.concept").returns "Concept"
      @view.render()
      @view.$el.should.have "table.terms"
      @view.$(".terms th").eq(0).should.have.text "Term"
      @view.$(".terms th").eq(1).should.have.text "Language"
      @view.$(".terms th").eq(2).should.have.text "Concept"

    it "renders terms", ->
      @view.model.set "hits", [
        result:
          value: "poet"
          lang: "en"
          concept_id: "503e248cd198795712000005"
      ]
      @view.render()
      @view.$(".terms tbody tr:first td").eq(0).should.have.text "poet"
      @view.$(".terms tbody tr:first td").eq(1).should.have.text "en"
      @view.$(".terms tbody tr:first td").eq(2).should.have "a[href='/concepts/503e248cd198795712000005']"
      @view.$(".terms tbody tr:first td a").should.have.text "503e248cd198795712000005"

    it "renders top 10 terms only", ->
      @view.model.set "hits",
        for n in [1..25]
          result:
            value: "term#{n}"
            lang: "en"
            concept_id: "503e248cd1987957120000#{n + 10}"
      @view.render()
      @view.$("tbody tr").length.should.equal 10

    it "is triggered on model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

      
