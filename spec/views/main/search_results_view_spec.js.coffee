#= require spec_helper
#= require views/main/search_results_view

describe "Coreon.Views.Main.SearchResultsView", ->
   
  beforeEach ->
    @view = new Coreon.Views.Main.SearchResultsView
      model:
        terms: new Backbone.Model(hits: [])
        concepts: new Backbone.Model(hits: [])
        tnodes: new Backbone.Model(hits: [])
    for name, search of @view.model
      search.query = -> "" 

  it "is a backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  describe "#initialize", ->
     
    it "creates term results view", ->
      @view.terms.should.be.an.instanceof Coreon.Views.Main.SearchResultsTermsView
      @view.terms.model.should.equal @view.model.terms

    it "creates concept results view", ->
      @view.concepts.should.be.an.instanceof Coreon.Views.Main.SearchResultsConceptsView
      @view.concepts.model.should.equal @view.model.concepts

    it "creates tnodes results view", ->
      @view.tnodes.should.be.an.instanceof Coreon.Views.Main.SearchResultsTnodesView
      @view.tnodes.model.should.equal @view.model.tnodes

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
