#= require spec_helper
#= require views/concepts/concept_label_view

describe "Coreon.Views.Concepts.ConceptLabelView", ->

  beforeEach ->
    @concept = _(new Backbone.Model).extend
      label: -> "poem"
      hit: -> false
    @view = new Coreon.Views.Concepts.ConceptLabelView model: @concept

  afterEach ->
    @view.destroy()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates link as container", ->
    @view.$el.should.match "a.concept-label"

  describe "#initialize", ->

    beforeEach ->
      @concept = new Backbone.Model

  describe "#render", ->
    beforeEach ->
      Coreon.application = new Backbone.Model
        session: new Backbone.Model
          current_repository_id: "coffeebabe23"
      @view.model.id = "1234"

    it "can be chained", ->
      @view.render().should.equal @view

    it "renders url to concept", ->
      @view.render()
      @view.$el.should.have.attr "href", "/coffeebabe23/concepts/1234"

    it "renders label", ->
      @view.model.set "label", "Zitrone", silent: true
      @view.render()
      @view.$el.should.have.text "Zitrone"

    it "is triggered on model changes", ->
      @view.render = @spy()
      @view.initialize model: new Backbone.Model
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

    it "classifies as hit when true", ->
      @concept.set "hit", new Backbone.Model, silent: true
      @view.render()
      @view.$el.should.have.class "hit"

    it "does not classify as hit when false", ->
      @concept.set "hit", new Backbone.Model, silent: true
      @view.render()
      @concept.set "hit", null
      @view.render()
      @view.$el.should.not.have.class "hit"

  describe "#appendTo", ->

    it "appends $el", ->
      @view.appendTo "#konacha"
      $("#konacha").should.have ".concept-label"

    it "delegates events", ->
      @view.delegateEvents = @spy()
      @view.appendTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

  describe "#destroy", ->

    it "removes $el", ->
      @view.appendTo "#konacha"
      @view.destroy()
      $("#konacha").should.not.have ".concept-label"

    it "disposes events on model", ->
      @view.render = @spy()
      @view.initialize model: new Backbone.Model
      @view.destroy()
      @view.model.trigger "change"
      @view.render.should.not.have.been.called
