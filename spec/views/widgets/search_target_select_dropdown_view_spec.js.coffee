#= require spec_helper
#= require views/widgets/search_target_select_dropdown_view
#= require models/search_type

describe "Coreon.Views.Widgets.SearchTargetSelectDropdownView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchTargetSelectDropdownView
      model: new Coreon.Models.SearchType
     
  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-search-target-select-dropdown"

  describe "#render", ->
    
    it "is chainable", ->
      @view.render().should.equal @view

    it "renders list with options", ->
      @view.model.set "options", ["all", "definition", "terms"]
      I18n.t.withArgs("search.target.all.label").returns "All"
      I18n.t.withArgs("search.target.definition.label").returns "Definition"
      I18n.t.withArgs("search.target.terms.label").returns "Terms"
      @view.render()
      @view.$el.should.have "ul.options"
      @view.$("ul li.option").eq(0).should.have.text "All"
      @view.$("ul li.option").eq(1).should.have.text "Definition"
      @view.$("ul li.option").eq(2).should.have.text "Terms"

    it "marks selected option", ->
      @view.model.set "selected", 0
      @view.render()
      @view.$("ul li.option").eq(0).should.have.class "selected"

  describe "#onClick", ->
    
    beforeEach ->
      @event = jQuery.Event "click"

    it "is triggered by click", ->
      @view.onClick = sinon.spy()
      @view.delegateEvents()
      @view.$el.trigger @event
      @view.onClick.should.have.been.calledWith @event

    it "hides itself", ->
      @view.undelegateEvents = sinon.spy()
      @view.remove = sinon.spy()
      @view.onClick @event
      @view.undelegateEvents.should.have.been.calledOnce
      @view.remove.should.have.been.calledOnce

  describe "#onSelect", ->
    
    beforeEach ->
      @event = jQuery.Event "click"

    it "updates selection on model", ->
      @view.model.set
        selectedTypeIndex: 1
        availableTypes: ["one", "two", "three"]
      @view.render()
      @view.$("li:last").trigger @event
      @view.model.get("selectedTypeIndex").should.equal 2
      @view.model.getSelectedType().should.equal "three"
