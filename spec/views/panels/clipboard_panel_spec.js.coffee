#= require spec_helper
#= require views/panels/clipboard_panel


describe "Coreon.Views.Panels.ClipboardPanel", ->

  panel = null
  view = null

  beforeEach ->
    sinon.stub I18n, "t"

    @clips = new Backbone.Collection
    sinon.stub Coreon.Collections.Clips, "collection", => @clips
    @labels = []
    sinon.stub Coreon.Views.Concepts, "ConceptLabelView", =>
      label = new Backbone.View arguments...
      label.render = sinon.stub().returns label
      sinon.spy label, "remove"
      @labels.push label
      label

    panel = new Backbone.Model
    view = new Coreon.Views.Panels.ClipboardPanel
      panel: panel

  afterEach ->
    I18n.t.restore()
    Coreon.Collections.Clips.collection.restore()
    Coreon.Views.Concepts.ConceptLabelView.restore()

  it "is a panel view", ->
    view.should.be.an.instanceof Coreon.Views.Panels.PanelView

  it "creates container", ->
    view.$el.should.have.id "coreon-clipboard"

  describe "#initialize()", ->

    beforeEach ->
      sinon.spy view, "droppableOn"

    afterEach ->
      view.droppableOn.restore()

    it 'calls super implementation', ->
      sinon.spy Coreon.Views.Panels.PanelView::, 'initialize'
      try
        panel = new Backbone.Model
        view.initialize panel: panel
        original = Coreon.Views.Panels.PanelView::initialize
        expect(original).to.have.been.calledOnce
        expect(original).to.have.been.calledWith panel: panel
      finally
        Coreon.Views.Panels.PanelView::initialize.restore()

    it "renders template skeleton", ->
      I18n.t.withArgs("widgets.clipboard.title").returns "Clipboard"
      view.initialize panel: panel
      title = view.$( '.titlebar h3' )
      expect( title ).to.exist
      expect( title ).to.have.text 'Clipboard'

    it "creates droppable from ul", ->
      view.initialize panel: panel
      view.droppableOn.should.have.been.calledOnce
      view.droppableOn.should.have.been.calledWith view.$("ul")

    it "uses function for acceptance test", ->
      view.dropItemAcceptance = sinon.spy()
      view.initialize panel: panel
      view.droppableOn.firstCall.args[2].accept()
      view.dropItemAcceptance.should.have.been.calledOnce

    it "droppable will identified with 'clipboard'", ->
      view.initialize panel: panel
      view.droppableOn.firstCall.args[1].should.equal "ui-droppable-clipboard"

  describe "render()", ->

    beforeEach ->
      @collection = new Backbone.Collection
      view.collection = =>
        @collection

    it "can be chained", ->
      view.render().should.equal view

    it "renders clips", ->
      view.collection().reset [
        { id: "clip1" }
        { id: "clip2" }
      ], silent: yes
      view.render()
      Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledTwice
      Coreon.Views.Concepts.ConceptLabelView.firstCall.should.have.been.calledWith model: @collection.at 0
      Coreon.Views.Concepts.ConceptLabelView.secondCall.should.have.been.calledWith model: @collection.at 1
      for label in @labels
        label.render.should.have.been.calledOnce
        $.contains(view.$("ul")[0], label.el).should.be.true
        view.labels.should.contain label

    it "clears previously rendered clips", ->
      view.collection().reset [ id: "clip" ], silent: yes
      view.render()
      view.collection().reset [], silent: yes
      view.render()
      view.labels.should.eql []
      @labels[0].remove.should.have.been.calledOnce
      view.$("ul").should.be.empty

  describe "clear()", ->

    it "clears the collection", ->
      @clips.add new Backbone.Model, silent:true
      @clips.length.should.equal 1
      view.clear()
      @clips.length.should.equal 0

  context "drop item acceptance", ->

    beforeEach ->
      @clips.reset [], silent: true
      @drop_el = $('<div data-drag-ident="c0ffeebabe">')
      @drop_model = new Backbone.Model id: "c0ffeebabe"

    it "accepts not enlisted drop items", ->
      view.dropItemAcceptance(@drop_el).should.be.true

    it "denies enlisted drop items", ->
      @clips.add @drop_model, silent: true
      view.dropItemAcceptance(@drop_el).should.be.false

  context "drop item", ->
    beforeEach ->
      sinon.stub @clips, "add"
      @drop = draggable: $('<div id="c0ffeebabe">')
      sinon.stub Coreon.Models.Concept, "find", -> new Backbone.Model id: "c0ffeebabe"

    afterEach ->
      @clips.add.restore()

    it "adds dropped items", ->
      view.onDropItem({}, @drop)
      @clips.add.should.have.been.calledOnce
      @clips.add.firstCall.args[0].id.should.equal "c0ffeebabe"

  context "event handling", ->

    beforeEach ->
      view.render = sinon.spy()
      view.initialize panel: panel

    it "rerenders when a model is added", ->
      @clips.trigger "add"
      view.render.should.have.been.calledOnce

    it "rerenders when a model is removed", ->
      @clips.trigger "remove"
      view.render.should.have.been.calledOnce

    it "rerenders on collection reset", ->
      @clips.trigger "reset", null, @clips
      view.render.should.have.been.calledOnce
