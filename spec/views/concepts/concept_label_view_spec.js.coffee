#= require spec_helper
#= require views/concepts/concept_label_view.js.coffee

describe "Coreon.Views.Concepts.ConceptLabelView", ->
  
  beforeEach ->
    @concept = _(new Backbone.Model).extend label: -> "poem"
    Coreon.application =
      concepts: _(new Backbone.Collection).extend
        getOrFetch: => @concept
    @view = new Coreon.Views.Concepts.ConceptLabelView "1234"

  afterEach ->
    @view.destroy()
    Coreon.application = null

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates link as container", ->
    @view.$el.should.match "a.concept-label"

  describe "#initialize", ->

    beforeEach ->
      @concept = new Backbone.Model
    
    it "gets model by id", ->
      Coreon.application.concepts.getOrFetch = sinon.stub()
      Coreon.application.concepts.getOrFetch.withArgs("1234abcf").returns @concept
      @view.initialize "1234abcf"
      @view.model.should.equal @concept

    it "sets model from options", ->
      sinon.spy Coreon.application.concepts, "getOrFetch"
      @view.initialize model: @concept
      @view.model.should.equal @concept
      Coreon.application.concepts.getOrFetch.should.not.have.been.called
    
  describe "#render", ->
    
    it "can be chained", ->
      @view.render().should.equal @view

    it "renders url to concept", ->
      @view.model.id = "1234"
      @view.render()
      @view.$el.should.have.attr "href", "/concepts/1234"

    it "renders label", ->
      @view.model.label = -> "Zitrone"
      @view.render()
      @view.$el.should.have.text "Zitrone"

    it "is triggered on model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

  describe "#appendTo", ->
    
    it "appends $el", ->
      @view.appendTo "#konacha"
      $("#konacha").should.have ".concept-label"

    it "delegates events", ->
      @view.delegateEvents = sinon.spy()
      @view.appendTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

  describe "#destroy", ->
    
    it "removes $el", ->
      @view.appendTo "#konacha"
      @view.destroy()
      $("#konacha").should.not.have ".concept-label"

    it "disposes events on model", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.destroy()
      @view.model.trigger "change"
      @view.render.should.not.have.been.called
      
