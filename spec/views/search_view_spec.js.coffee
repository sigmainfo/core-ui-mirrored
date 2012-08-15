#= require spec_helper
#= require views/search_view

describe "Coreon.Views.SearchView", ->
  
  beforeEach ->
    @view = new Coreon.Views.SearchView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View
    
  it "creates container", ->
    @view.$el.should.have.id "coreon-search"

  describe "#render", ->

    it "can be chained", ->
      @view.render().should.equal @view
      
    it "renders form", ->
      @view.render()
      @view.$el.should.have "form.search"

    it "renders query input", ->
      @view.render()
      @view.$el.should.have "input#coreon-search-query"
      @view.$("#coreon-search-query").should.have.attr "type", "text"
      @view.$("#coreon-search-query").should.have.attr "name", "search[query]"
      
