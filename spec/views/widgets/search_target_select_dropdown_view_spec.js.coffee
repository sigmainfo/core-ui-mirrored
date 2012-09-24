#= require spec_helper
#= require views/widgets/search_target_select_dropdown_view
#= require models/search_type

describe "Coreon.Views.Widgets.SearchTargetSelectDropdownView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchTargetSelectDropdownView
      model: new Coreon.Models.SearchType
     
  afterEach ->
    @view.undelegateEvents()
    I18n.t.restore()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

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

  describe "#onFocus", ->

    beforeEach ->
      @event = jQuery.Event "mouseover"
      @view.render()

    it "is triggered when hovering an option", ->
      @view.onFocus = sinon.spy()
      @view.delegateEvents()
      @view.$("li.option").eq(1).trigger @event
      @view.onFocus.should.have.been.calledWith @event 
      
    it "adds class to focused element only", ->
      @view.$("li.option").eq(1).addClass "focus"
      @view.$("li.option").eq(0).trigger @event
      @view.$("li.option").eq(0).should.have.class "focus"
      @view.$("li.option").eq(1).should.not.have.class "focus"

  describe "#onBlur", ->
    
    beforeEach ->
      @event = jQuery.Event "mouseout"
      @view.render()
    
    it "is triggered when hovering out of an option", ->
      @view.onBlur = sinon.spy()
      @view.delegateEvents()
      @view.$("li.option").eq(1).trigger @event
      @view.onBlur.should.have.been.calledWith @event

    it "is removes focus", ->
      @view.$("li.option").eq(0).addClass "focus"
      @view.$("li.option").eq(1).addClass "focus"
      @view.$("li.option").eq(1).trigger @event
      @view.$("li.option").eq(0).should.not.have.class "focus"
      @view.$("li.option").eq(1).should.not.have.class "focus"

  describe "#onKeydown", ->
    
    beforeEach ->
      @event = jQuery.Event "keydown"
      $("#konacha").append @view.render().$el

    it "is triggered by keydown", ->
      @view.onKeydown = sinon.spy()
      @view.delegateEvents()
      $(document).trigger @event
      @view.onKeydown.should.have.been.calledWith @event

    it "is not triggered after undelegating events", ->
      @view.onKeydown = sinon.spy()
      @view.delegateEvents()
      @view.undelegateEvents()
      $(document).trigger @event
      @view.onKeydown.should.not.have.been.called

    it "hides itself on <esc>", ->
      @view.undelegateEvents = sinon.spy()
      @view.remove = sinon.spy()
      @event.keyCode = 27
      @view.onKeydown @event
      @view.undelegateEvents.should.have.been.calledOnce
      @view.remove.should.have.been.calledOnce

    it "selects focused on <enter", ->
      @view.$("li.option").eq(1).addClass "focus"
      @view.undelegateEvents = sinon.spy()
      @view.remove = sinon.spy()
      @event.keyCode = 13
      @view.onKeydown @event
      @view.model.get("selectedTypeIndex").should.equal 1
      @view.undelegateEvents.should.have.been.calledOnce
      @view.remove.should.have.been.calledOnce

    it "simply keeps selection when nothing is focused on <enter>", ->
      @view.undelegateEvents = sinon.spy()
      @view.remove = sinon.spy()
      @event.keyCode = 13
      @view.onKeydown @event
      @view.model.get("selectedTypeIndex").should.equal 0
      @view.undelegateEvents.should.have.been.calledOnce
      @view.remove.should.have.been.calledOnce    

    it "moves focus down on <down>", ->
      @event.keyCode = 40
      @view.onKeydown @event
      @view.$("li.option").eq(0).should.have.class "focus"
      @view.onKeydown @event
      @view.onKeydown @event
      @view.$("li.option").eq(2).should.have.class "focus"
      @view.onKeydown @event
      @view.$("li.option").eq(2).should.have.class "focus"

    it "moves focus up on <up>", ->
      @view.$("li.option").eq(2).addClass "focus"
      @event.keyCode = 38
      @view.onKeydown @event
      @view.$("li.option").eq(1).should.have.class "focus"
      @view.onKeydown @event
      @view.onKeydown @event
      @view.$("li.option").eq(0).should.have.class "focus"
