#= require spec_helper
#= require views/widgets/search_view

describe "Coreon.Views.SearchView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchView

  afterEach ->
    I18n.t.restore()

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

    it "renders submit button", ->
      I18n.t.withArgs("search.submit").returns "Search"  
      @view.render()
      @view.$("form").should.have 'input[type="submit"]'
      @view.$('input[type="submit"]').val().should.equal "Search"

  describe "#submitHandler", ->

    beforeEach ->
      Backbone.history = navigate: sinon.spy()
      @event =
        stopPropagation: sinon.spy()
        preventDefault: sinon.spy()

    it "triggers on submit", ->
      sinon.spy @view, "submitHandler"
      @view.delegateEvents()
      @view.render()
      @view.$("form").trigger "submit"
      @view.submitHandler.should.have.been.calledOnce

    it "prevents default and stops propagation", ->
      @view.submitHandler @event
      @event.stopPropagation.should.have.been.calledOnce
      @event.preventDefault.should.have.been.calledOnce

    it "navigates to search result", ->
      @view.render()
      @view.$('input[name="search[query]"]').val "foo"
      @view.submitHandler @event
      Backbone.history.navigate.should.have.been.calledWith "concepts/search?search%5Bquery%5D=foo"

      
