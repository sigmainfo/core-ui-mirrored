#= require spec_helper
#= require views/widgets_view

describe "Coreon.Views.WidgetsView", ->

  beforeEach ->
    @view = new Coreon.Views.WidgetsView
    sinon.stub @view.search

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View


  it "creates container", ->
    @view.$el.should.have.id "coreon-widgets"
    

  it "creates search view", ->
    @view.search.should.be.an.instanceOf Coreon.Views.Widgets.SearchView
    
  describe "#render", ->

    beforeEach ->
      @view.search.render.returns @view.search

    it "is chainable", ->
      @view.render().should.equal @view
    
    it "renders search", ->
      @view.render()
      @view.$el.should.have "#coreon-search"
      @view.search.render.should.have.been.calledOnce
