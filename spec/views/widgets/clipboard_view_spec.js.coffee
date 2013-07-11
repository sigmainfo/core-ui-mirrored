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


  context "event handling", ->

    beforeEach ->
      @view.render = sinon.spy()

    it "rerenders on collection change", ->
      @clips.trigger "add"
      @view.render.should.have.been.calledOnce

    it "rerenders on collection reset", ->
      @clips.trigger "reset", null, @clips
      @view.render.should.have.been.calledOnce

