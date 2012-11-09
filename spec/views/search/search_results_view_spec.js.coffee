#= require spec_helper
#= require views/search/search_results_view

describe "Coreon.Views.Search.SearchResultsView", ->
   
  beforeEach ->
    @view = new Coreon.Views.Search.SearchResultsView
      models:
        terms: new Backbone.Model(hits: [])
        concepts: new Backbone.Model(hits: [])
        tnodes: new Backbone.Model(hits: [])
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

    it "creates tnodes results view", ->
      @view.tnodes.should.be.an.instanceof Coreon.Views.Search.SearchResultsTnodesView
      @view.tnodes.model.should.equal @view.options.models.tnodes

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
      
    it "renders tnodes results", ->
      @view.render()
      @view.$el.should.have ".search-results-tnodes"
      @view.$(".search-results-tnodes").should.have "h3"