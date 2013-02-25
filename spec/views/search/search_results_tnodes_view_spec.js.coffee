#= require spec_helper
#= require views/search/search_results_tnodes_view
#= require config/application

describe "Coreon.Views.Search.SearchResultsTnodesView", ->
  
  beforeEach ->
    Coreon.application = new Coreon.Application
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Search.SearchResultsTnodesView model: new Backbone.Model
    @view.model.set "hits", []

  afterEach ->
    Coreon.application.destroy()
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.class "search-results-tnodes"

  describe "#render", ->

    it "is chainable", ->
      @view.render().should.equal @view
    
    it "renders headline", ->
      I18n.t.withArgs("search.results.tnodes.headline").returns "Taxonomies"
      @view.render()
      @view.$el.should.have "h3"
      @view.$("h3").should.have.text "Taxonomies"

    it "renders table header", ->
      I18n.t.withArgs("search.results.tnodes.header.name").returns "Name"
      @view.render()
      @view.$el.should.have "table.tnodes"
      @view.$(".tnodes th").eq(0).should.have.text "Name"

    it "renders tnodes", ->
      @view.model.set "hits", [
        result:
          properties: [
            { key: "label", value: "poet" }
          ]
      ]
      @view.render()
      # console.log @view.model
      @view.$(".tnodes tbody tr:first td").eq(0).should.have.text "poet"

    it "renders top 10 tnodes only", ->
      @view.model.set "hits",
        for n in [1..25]
          result:
            name: "tnode#{n}"
      @view.render()
      @view.$("tbody tr").length.should.equal 10

    it "is triggered on model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

      
