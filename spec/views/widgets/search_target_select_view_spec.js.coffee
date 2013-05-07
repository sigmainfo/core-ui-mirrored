#= require spec_helper
#= require views/widgets/search_target_select_view
#= require models/search_type

describe "Coreon.Views.Widgets.SearchTargetSelectView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchTargetSelectView
      model: new Coreon.Models.SearchType

  afterEach ->
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView 

  it "creates container", ->
    @view.$el.should.have.id "coreon-search-target-select"

  describe "initialize()", ->
    
    it "creates dropdown", ->
      @view.dropdown.should.be.an.instanceof Coreon.Views.Widgets.SearchTargetSelectDropdownView 
      @view.dropdown.model.should.equal @view.model
      @view.subviews.should.eql [@view.dropdown]

  describe "render()", ->

    it "is chainable", ->
      @view.render().should.equal @view

    it "renders hint", ->
      @view.model.set
        options: ["all"]
        selected: 0
      I18n.t.withArgs("search.target.all.hint").returns "Search all"
      @view.render()
      @view.$el.should.have ".hint"
      @view.$(".hint").should.have.text "Search all"

    it "renders toggle", ->
      @view.render()
      @view.$el.should.have ".toggle"

    it "is triggered by changes on model", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.set "selected", 1
      @view.render.should.have.been.calledOnce
      

  describe "showDropdown()", ->

    beforeEach ->
      @event = jQuery.Event "click"
      $("#konacha").append $('<div id="coreon-modal">')
      $("#konacha").append $('<input id="coreon-search-query">')
      @view.render()
    
    it "is triggered by click on toggle", ->
      @view.showDropdown = sinon.spy()
      @view.delegateEvents()
      @view.$(".toggle").trigger @event
      @view.showDropdown.should.have.been.calledWith @event
    
    it "renders dropdown as an overlay", ->
      @view.dropdown.delegateEvents = sinon.spy()
      @view.$(".toggle").trigger @event
      $("#coreon-modal").should.have "#coreon-search-target-select-dropdown"
      @view.dropdown.delegateEvents.should.have.been.calledOnce

    it "adjusts width and position to match query input", ->
      input = $("#coreon-search-query")
      input.css
        position: "absolute"
        top: 10
        left: 25
        width: 200
        height: 20
        padding: 5
        margin: 30
        border: "2px solid red"
      @view.$(".toggle").trigger @event
      list = @view.dropdown.$ ".options"
      list.width().should.equal 213
      list.position().should.have.property("left").closeTo(56, 0.5)
      list.position().should.have.property("top").closeTo(74, 0.5)

  describe "onFocus()", ->

    beforeEach ->
      @event = jQuery.Event "click"
      I18n.t.withArgs("search.target.all.hint").returns "Search all"
      @view.render().$el.appendTo $("#konacha")

    it "is triggered by click on link", ->
      @view.onFocus = sinon.spy()
      @view.delegateEvents()
      @view.$(".hint").trigger @event
      @view.onFocus.should.have.been.calledWith @event

    it "hides hint", ->
      @view.onFocus @event
      @view.$(".hint").should.not.be.visible
      
    it "triggers event", ->
      spy = sinon.spy()
      @view.on "focus", spy
      @view.onFocus @event
      spy.should.have.been.calledOnce

  describe "hideHint()", ->

    beforeEach ->
      @view.render().$el.appendTo $("#konacha")
    
    it "hides hint", ->
      @view.hideHint()
      @view.$(".hint").should.not.be.visible
    
  describe "revealHint()", ->

    beforeEach ->
      @view.render().$el.appendTo $("#konacha")
      @view.hideHint()
    
    it "reveals hint", ->
      @view.revealHint()
      @view.$(".hint").should.be.visible
