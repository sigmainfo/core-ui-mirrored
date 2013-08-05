#= require spec_helper
#= require views/concepts/concept_label_view

describe "Coreon.Views.Concepts.ConceptLabelView", ->

  beforeEach ->
    @concept = _(new Backbone.Model).extend
      label: -> "poem"
      hit: -> false
    sinon.stub Coreon.Models.Concept, "find"
    Coreon.Models.Concept.find.withArgs("1234").returns @concept
    @view = new Coreon.Views.Concepts.ConceptLabelView id: "1234"

  afterEach ->
    @view.destroy()
    Coreon.Models.Concept.find.restore()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates link as container", ->
    @view.$el.should.match "a.concept-label"

  describe "#initialize", ->

    beforeEach ->
      @concept = new Backbone.Model

    it "gets model by id", ->
      Coreon.Models.Concept.find.withArgs("1234abcf").returns @concept
      @view.initialize id: "1234abcf"
      @view.model.should.equal @concept

    it "sets model from options", ->
      Coreon.Models.Concept.find.reset()
      @view.initialize model: @concept
      @view.model.should.equal @concept
      Coreon.Models.Concept.find.should.not.have.been.calledWith "1234"

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
      @view.render = sinon.spy()
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

    context "draggable", ->
      beforeEach ->
        sinon.stub @view.$el, "draggable"

      afterEach ->
        @view.$el.draggable.restore()

      it "handles events", ->
        @view.events.dragstart.should.equal "onStartDragging"
        @view.events.dragstop.should.equal "onStopDragging"

      it "makes $el draggable", ->
        @view.render()
        @view.$el.draggable.should.have.been.calledOnce

      it "adds drag ghost to modal layer", ->
        @view.render()
        args = @view.$el.draggable.firstCall.args[0]
        args.helper.should.equal "clone"
        args.appendTo.should.equal "#coreon-modal"

      it "adds class to dragged source element", ->
        @view.onStartDragging()
        @view.$el.should.have.class "ui-draggable-dragged"

      it "adds class to dragged source element", ->
        @view.onStopDragging()
        @view.$el.should.not.have.class "ui-draggable-dragged"


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
      @view.initialize model: new Backbone.Model
      @view.destroy()
      @view.model.trigger "change"
      @view.render.should.not.have.been.called
