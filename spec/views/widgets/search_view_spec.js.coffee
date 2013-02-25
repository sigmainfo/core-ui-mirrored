#= require spec_helper
#= require views/widgets/search_view

describe "Coreon.Views.SearchView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchView

  afterEach ->
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceOf Coreon.Views.CompositeView
    
  it "creates container", ->
    @view.$el.should.have.id "coreon-search"


  describe "#initialize", ->
    
    it "creates selector", ->
      @view.selector.should.be.an.instanceof Coreon.Views.Widgets.SearchTargetSelectView

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
      @view.$("#coreon-search-query").should.have.attr "name", "q"

    it "renders submit button", ->
      I18n.t.withArgs("search.submit").returns "Search"  
      @view.render()
      @view.$("form").should.have 'input[type="submit"]'
      @view.$('input[type="submit"]').val().should.equal "Search"

    it "renders select", ->
      @view.render()
      @view.$el.should.have "#coreon-search-target-select"
      @view.$("#coreon-search-target-select").should.have ".hint"
      

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
      @view.$('input[name="q"]').val "foo"
      @view.submitHandler @event
      Backbone.history.navigate.should.have.been.calledWith "search/foo", trigger: true

    it "navigates to concept search with type", ->
      @view.render()
      @view.$('input[name="q"]').val "foo"
      @view.searchType.getSelectedType = -> "terms"
      @view.submitHandler @event
      Backbone.history.navigate.should.have.been.calledWith "concepts/search/terms/foo", trigger: true

  describe "#onClickedToFocus", ->

    it "is triggered by select", ->
      spy = sinon.spy()
      @view.onClickedToFocus = spy
      @view.initialize()
      @view.selector.trigger "focus"
      spy.should.have.been.calledOnce

    # disabled because it randomly fails
    # it "puts focus on search input", ->
    #   @view.render().$el.appendTo $("#konacha")
    #   @view.onClickedToFocus()
    #   @view.$("#coreon-search-query").should.match ":focus"

  describe "#onFocus", ->

    beforeEach ->
      @event = jQuery.Event "focusin"
      @view.render().$el.appendTo $("#konacha")

    it "is triggered by focus of input", ->
      @view.onFocus = sinon.spy()
      @view.delegateEvents()
      @view.$("input#coreon-search-query").trigger @event
      @view.onFocus.should.have.been.calledWith @event

    it "hides hint", ->
      @view.onFocus @event
      @view.selector.$(".hint").should.not.be.visible

  describe "#onBlur", ->
    
    beforeEach ->
      @event = jQuery.Event "blur"
      @view.render().$el.appendTo $("#konacha")
      @view.selector.hideHint()

    it "is triggered by focus of input", ->
      @view.onBlur = sinon.spy()
      @view.delegateEvents()
      @view.$("input#coreon-search-query").trigger @event
      @view.onBlur.should.have.been.calledWith @event

    it "reveals hint", ->
      @view.onBlur @event
      @view.selector.$(".hint").should.be.visible

    it "does not reveal hint when not empty", ->
      @view.$("input#coreon-search-query").val "Zitrone"
      @view.onBlur @event
      @view.selector.$(".hint").should.not.be.visible

  describe "#onChangeSelectedType", ->

    beforeEach ->
      @view.render().$el.appendTo $("#konacha")

    it "is triggered by change on model", ->
      @view.onChangeSelectedType = sinon.spy()
      @view.initialize()
      @view.searchType.set "selectedTypeIndex", 2
      @view.onChangeSelectedType.should.have.been.calledOnce

    it "empties select", -> 
      @view.$("input#coreon-search-query").val().should.equal ""
