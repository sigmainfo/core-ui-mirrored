#= require spec_helper
#= require views/search/search_results_view

describe "Coreon.Views.Search.SearchResultsView", ->

  beforeEach ->
    Coreon.Helpers.repositoryPath = (s)-> "/coffee23/#{s}"
    Coreon.Helpers.can = -> true
    @view = new Coreon.Views.Search.SearchResultsView
      models:
        terms: new Backbone.Model(hits: [])
        concepts: new Backbone.Model(hits: [])
    for name, search of @view.options.models
      search.query = -> "" 

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  describe "#initialize", ->

    it "creates term results view", ->
      @view.terms.should.be.an.instanceof Coreon.Views.Search.SearchResultsTermsView
      @view.terms.model.should.equal @view.options.models.terms

    it "creates concept results view", ->
      @view.concepts.should.be.an.instanceof Coreon.Views.Search.SearchResultsConceptsView
      @view.concepts.model.should.equal @view.options.models.concepts

  describe "#render", ->

    it "is chainable", ->
      @view.render().should.equal @view

    it "renders term results", ->
      @view.render()
      @view.$el.should.have ".search-results-terms"
      @view.$(".search-results-terms").should.have "h3"


    it "renders concept results", ->
      @view.render()
      @view.$el.should.have ".search-results-concepts"
      @view.$(".search-results-concepts").should.have "h3"
