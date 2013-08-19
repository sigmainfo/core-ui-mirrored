#= require spec_helper
#= require views/widgets/clipboard_view


describe "Coreon.Views.Widgets.ClipboardView", ->

  beforeEach ->
    sinon.stub I18n, "t"

    @clips = new Backbone.Collection
    sinon.stub Coreon.Collections.Clips, "collection", => @clips
    Coreon.Views.Concepts.ConceptLabelView = Backbone.View

    @view = new Coreon.Views.Widgets.ClipboardView
 
  afterEach ->
    I18n.t.restore()
    Coreon.Collections.Clips.collection.restore()

  it "is a backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-clipboard"
    @view.$el.should.have.class "widget"

  it "renders template skeleton", ->
    I18n.t.withArgs("clipboard.title").returns "Clipboard"
    @view.render()
    @view.$el.should.have ".titlebar h4"
    @view.$(".titlebar h4").should.have.text "Clipboard"

  it "renders titlebar only once", ->
    @view.render()
    @view.render()
    @view.$(".titlebar").size().should.equal 1

  it "can be chained", ->
    @view.render().should.equal @view

  it "clears the collection", ->
    @clips.add new Backbone.Model, silent:true
    @clips.length.should.equal 1
    @view.clear()
    @clips.length.should.equal 0

  describe "initialize()", ->

    beforeEach ->
      sinon.spy @view, "droppableOn"

    afterEach ->
      @view.droppableOn.restore()

    it "creates droppable from $el", ->
      @view.initialize()
      @view.droppableOn.should.have.been.calledOnce

    it "uses function for acceptance test", ->
      @view.dropItemAcceptance = sinon.spy()
      @view.initialize()
      @view.droppableOn.firstCall.args[2].accept()
      @view.dropItemAcceptance.should.have.been.calledOnce

    it "droppable will identified with 'clipboard'", ->
      @view.initialize()
      @view.droppableOn.firstCall.args[1].should.equal "ui-droppable-clipboard"


  context "drop item acceptance", ->

    beforeEach ->
      @clips.reset [], silent: true
      @drop_el = $('<div data-drag-ident="c0ffeebabe">')
      @drop_model = new Backbone.Model _id: "c0ffeebabe"

    it "accepts not enlisted drop items", ->
      @view.dropItemAcceptance(@drop_el).should.be.true

    it "denies enlisted drop items", ->
      @clips.add @drop_model, silent: true
      @view.dropItemAcceptance(@drop_el).should.be.false

  context "drop item", ->
    beforeEach ->
      sinon.stub @clips, "add"
      @drop = draggable: $('<div id="c0ffeebabe">')
      sinon.stub Coreon.Models.Concept, "find", -> new Backbone.Model _id: "c0ffeebabe"

    afterEach ->
      @clips.add.restore()

    it "adds dropped items", ->
      @view.onDropItem({}, @drop)
      @clips.add.should.have.been.calledOnce
      @clips.add.firstCall.args[0].id.should.equal "c0ffeebabe"

  context "event handling", ->

    beforeEach ->
      @view.render = sinon.spy()
      @view.initialize()

    it "rerenders when a model is added", ->
      @clips.trigger "add"
      @view.render.should.have.been.calledOnce

    it "rerenders when a model is removed", ->
      @clips.trigger "remove"
      @view.render.should.have.been.calledOnce

    it "rerenders on collection reset", ->
      @clips.trigger "reset", null, @clips
      @view.render.should.have.been.calledOnce
