#= require spec_helper
#= require views/widgets/search_target_select_view

describe "Coreon.Views.Widgets.SearchTargetSelectView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchTargetSelectView

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View 

  it "creates container", ->
    @view.$el.should.have.id "coreon-search-target-select"

  describe "#initialize", ->
    
    it "creates dropdown", ->
      @view.dropdown.should.be.an.instanceof Coreon.Views.Widgets.SearchTargetSelectDropdownView 
      @view.dropdown.model.should.equal @view.searchType
      @view.searchType.get("options").should.eql ["all", "definition", "terms"] 
      @view.searchType.get("selected").should.eql 0

  describe "#render", ->

    it "is chainable", ->
      @view.render().should.equal @view

    it "renders hint", ->
      I18n.t.withArgs("search.target.all.hint").returns "Search all"
      @view.render()
      @view.$el.should.have ".hint"
      @view.$(".hint").should.have.text "Search all"
   
    it "renders toggle", ->
      @view.render()
      @view.$el.should.have ".toggle"

  describe "#showDropdown", ->

    beforeEach ->
      @event = jQuery.Event "click"
      @view.render()
    
    it "is triggered by click on toggle", ->
      @view.showDropdown = sinon.spy()
      @view.delegateEvents()
      @view.$(".toggle").trigger @event
      @view.showDropdown.should.have.been.calledWith @event
    
    it "renders dropdown as an overlay", ->
      $("#konacha").append $('<div id="coreon-modal">')
      @view.$(".toggle").trigger @event
      $("#coreon-modal").should.have "#coreon-search-target-select-dropdown"
      
