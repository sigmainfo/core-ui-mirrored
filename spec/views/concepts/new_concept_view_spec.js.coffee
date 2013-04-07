#= require spec_helper
#= require views/concepts/new_concept_view

describe "Coreon.Views.Concepts.NewConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    sinon.stub Coreon.Views.Concepts.Shared, "BroaderAndNarrowerView", (options) =>
      @broaderAndNarrower = new Backbone.View options
    @view = new Coreon.Views.Concepts.NewConceptView
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "is classified as new concept", ->
    @view.$el.should.have.class "concept"
    @view.$el.should.have.class "new"

  describe "initialize()", ->
  
    it "creates view for broader & narrower section", ->
      should.exist @view.broaderAndNarrower
      @view.broaderAndNarrower.should.equal @broaderAndNarrower
      @view.broaderAndNarrower.should.have.property "model", @view.model

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view
  
    it "renders caption", ->
      @view.model.set "label", "<New concept>", silent: true
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$("h2.label").should.have.text "<New concept>"

    context "broader and narrower", ->
      
      it "renders view", ->
        @view.broaderAndNarrower.render = sinon.spy()
        @view.render()
        @view.broaderAndNarrower.render.should.have.been.calledOnce

      it "renders view only once", ->
        @view.broaderAndNarrower.render = sinon.spy()
        @view.render()
        @view.render()
        @view.broaderAndNarrower.render.should.have.been.calledOnce

      it "appends el", ->
        @view.render()
        $.contains(@view.el, @view.broaderAndNarrower.el).should.be.true

    context "form", ->

      it "renders submit button", ->
        I18n.t.withArgs("concept.create").returns "Create concept"
        @view.render()
        @view.$el.should.have "form"
        @view.$el.should.have 'form input[type="submit"]'
        @view.$('form input[type="submit"]').should.have.attr "value", "Create concept"

      it "renders a cancel button", ->
        I18n.t.withArgs("form.cancel").returns "Cancel"
        @view.render()
        @view.$el.should.have "a.cancel"
        @view.$("a.cancel").should.have.attr "href", "javascript:history.back()"
        @view.$("a.cancel").should.have.text "Cancel"

  describe "remove()", ->

    beforeEach ->
      sinon.stub Backbone.View::, "remove", -> @

    afterEach ->
      Backbone.View::remove.restore()

    it "can be chained", ->
      @view.remove().should.equal @view
    
    it "removes broader and narrower view", ->
      @view.broaderAndNarrower.remove = sinon.spy()
      @view.remove()
      @view.broaderAndNarrower.remove.should.have.been.calledOnce

    it "calls super implementation", ->
      @view.remove()
      Backbone.View::remove.should.have.been.calledOn @view
