#= require spec_helper
#= require views/widgets/search_view

describe "Coreon.Views.Widgets.SearchView", ->

  beforeEach ->
    @stub I18n, "t"

    @stub Coreon.Views.Widgets, "SearchTargetSelectView", =>
      @select = new Backbone.View
      @select.render = @stub().returns @select
      @select.hideHint = @spy()
      @select.revealHint = @spy()
      @select

    model = new Backbone.Model
    model.getSelectedType = -> "all"
    @view = new Coreon.Views.Widgets.SearchView
      model: model

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-search"

  describe "render()", ->

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
      I18n.t.withArgs('search.submit.label').returns "Search"
      @view.render()
      @view.$("form").should.have 'input[type="submit"]'
      @view.$('input[type="submit"]').val().should.equal "Search"

    it "renders search type select", ->
      @view.render()
      Coreon.Views.Widgets.SearchTargetSelectView.should.have.been.calledOnce
      Coreon.Views.Widgets.SearchTargetSelectView.should.have.been.calledWithNew
      Coreon.Views.Widgets.SearchTargetSelectView.should.have.been.calledWith model: @view.model
      @select.render.should.have.been.calledOnce
      $.contains(@view.el, @select.el).should.be.true

    it "removes old search type select", ->
      @view.render()
      old = @select
      old.remove = @spy()
      @view.render()
      old.remove.should.have.been.calledOnce

  describe "submitHandler()", ->

    beforeEach ->
      Coreon.Helpers.repositoryPath = (s)-> "/coffee23/#{s}"
      @stub Backbone.history, "navigate"
      @stub Backbone.history, "loadUrl"
      Backbone.history.fragment = "coffee23"
      @event = $.Event "submit"

    it "triggers on submit", ->
      @spy @view, "submitHandler"
      @view.delegateEvents()
      @view.render()
      @view.$("form").trigger @event
      @view.submitHandler.should.have.been.calledOnce

    it "prevents default and stops propagation", ->
      @event.preventDefault = @spy()
      @view.submitHandler @event
      @event.preventDefault.should.have.been.calledOnce

    it "navigates to search result", ->
      @view.render()
      @view.$('input[name="q"]').val "foo"
      Backbone.history.fragment = "coffee23/concepts/myconcept567hjkg"
      @view.model.getSelectedType = -> "all"
      @view.submitHandler @event
      Backbone.history.navigate.should.have.been.calledWith "coffee23/concepts/search/foo"
      Backbone.history.loadUrl.should.have.been.calledOnce

    it "navigates to concept search with type", ->
      @view.render()
      @view.$('input[name="q"]').val "foo"
      @view.model.getSelectedType = -> "terms"
      Backbone.history.fragment = "coffee23/concepts/myconcept567hjkg"
      @view.submitHandler @event
      Backbone.history.navigate.should.have.been.calledWith "coffee23/concepts/search/terms/foo"
      Backbone.history.loadUrl.should.have.been.calledOnce

  describe "onClickedToFocus()", ->

    it "is triggered by select", ->
      @view.onClickedToFocus = @spy()
      @view.render()
      @select.trigger "focus"
      @view.onClickedToFocus.should.have.been.calledOnce

    it "is not triggered by removed select", ->
      @view.onClickedToFocus = @spy()
      @view.render()
      old = @select
      @view.render()
      old.trigger "focus"
      @view.onClickedToFocus.should.not.have.been.called

    it "puts focus on search input", ->
      spy = @spy()
      @view.$ = @stub()
      @view.$.withArgs("input#coreon-search-query").returns focus: spy
      @view.onClickedToFocus()
      spy.should.have.been.calledOnce

  describe "onFocus()", ->

    beforeEach ->
      @event = jQuery.Event "focusin"
      @view.render().$el.appendTo $("#konacha")

    it "is triggered by focus of input", ->
      @view.onFocus = @spy()
      @view.delegateEvents()
      @view.$("input#coreon-search-query").trigger @event
      @view.onFocus.should.have.been.calledWith @event

    it "hides hint", ->
      @view.onFocus @event
      @select.hideHint.should.have.been.calledOnce

  describe "onBlur()", ->

    beforeEach ->
      @event = jQuery.Event "blur"
      @view.render().$el.appendTo $("#konacha")

    it "is triggered by focus of input", ->
      @view.onBlur = @spy()
      @view.delegateEvents()
      @view.$("input#coreon-search-query").trigger @event
      @view.onBlur.should.have.been.calledWith @event

    it "reveals hint", ->
      @view.onBlur @event
      @select.revealHint.should.have.been.calledOnce

    it "does not reveal hint when not empty", ->
      @view.$("input#coreon-search-query").val "Zitrone"
      @view.onBlur @event
      @select.revealHint.should.not.have.been.called

  describe "onChangeSelectedType()", ->

    beforeEach ->
      @view.render().$el.appendTo $("#konacha")

    it "is triggered by change on model", ->
      @view.onChangeSelectedType = @spy()
      @view.initialize()
      @view.model.trigger "change:selectedTypeIndex"
      @view.onChangeSelectedType.should.have.been.calledOnce

    it "empties select", ->
      expect( @view.$("input#coreon-search-query").val() ).to.equal ""
