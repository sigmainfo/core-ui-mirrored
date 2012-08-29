#= require spec_helper
#= require views/widgets/search_target_select_dropdown_view

describe "Coreon.Views.Widgets.SearchTargetSelectDropdownView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.SearchTargetSelectDropdownView
      model: new Backbone.Model
        options: ["all", "definition", "terms"]
        selected: 0
  
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

      
