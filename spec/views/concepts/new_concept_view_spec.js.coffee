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

    context "properties", ->
      
      it "renders section with title", ->
        I18n.t.withArgs("properties.title").returns "Properties"
        @view.render()
        @view.$el.should.have ".properties"
        @view.$(".properties").should.match "section"
        @view.$el.should.have ".properties h3"
        @view.$("section.properties h3").should.have.text "Properties"

      it "renders link for adding a property", ->
        I18n.t.withArgs("properties.add").returns "Add Property"
        @view.render()
        @view.$el.should.have "a.add-property"
        @view.$("a.add-property").should.have.text "Add Property"

  describe "addProperty()", ->

    beforeEach ->
      @event = $.Event "click"
      @view.render()
    
    it "is triggered by click on action", ->
      @view.addProperty = sinon.spy()
      @view.delegateEvents() 
      @view.$("a.add-property").trigger @event
      @view.addProperty.should.have.been.calledOnce
      @view.addProperty.should.have.been.calledWith @event

    it "appends property input set", ->
      I18n.t.withArgs("property.key").returns "Key"
      I18n.t.withArgs("property.value").returns "Value"
      I18n.t.withArgs("property.lang").returns "Language"

      @view.addProperty @event
      @view.$el.should.have ".properties fieldset.property"

      @view.$el.should.have ".property .key"
      key = @view.$(".property .key")
      key.should.have.class "required"
      @view.$el.should.have ".property .key input"
      keyInput = @view.$(".property .key input")
      keyInput.should.have.attr "type", "text"
      keyInput.should.have.attr "name", "concept[properties][0][key]"
      @view.$el.should.have ".property .key label"
      keyLabel = @view.$(".property .key label")
      keyLabel.should.have.text "Key"

      @view.$el.should.have ".property .value"
      value = @view.$(".property .value")
      value.should.have.class "required"
      @view.$el.should.have ".property .value input"
      valueInput = @view.$(".property .value input")
      valueInput.should.have.attr "type", "text"
      valueInput.should.have.attr "name", "concept[properties][0][value]"
      @view.$el.should.have ".property .value label"
      valueLabel = @view.$(".property .value label")
      valueLabel.should.have.text "Value"

      @view.$el.should.have ".property .lang"
      lang = @view.$(".property .lang")
      lang.should.not.have.class "required"
      @view.$el.should.have ".property .lang input"
      langInput = @view.$(".property .lang input")
      langInput.should.have.attr "type", "text"
      langInput.should.have.attr "name", "concept[properties][0][lang]"
      @view.$el.should.have ".property .lang label"
      langLabel = @view.$(".property .lang label")
      langLabel.should.have.text "Language"

    it "enumerates appended property input sets", ->
      @view.addProperty @event
      @view.addProperty @event
      @view.$el.should.have 'input[name="concept[properties][0][key]"]'
      @view.$el.should.have 'input[name="concept[properties][1][key]"]'
        
  describe "create()", ->

    beforeEach ->
      @event = $.Event "submit"
      sinon.stub Backbone.history, "navigate"
      @promise =
        done: (@done) =>
      @view.model.save = sinon.stub().returns @promise
      @view.render()
    
    afterEach ->
      Backbone.history.navigate.restore()

    it "is triggered on form submit", ->
      @view.create = sinon.spy()
      @view.delegateEvents()
      @view.$("form").trigger @event
      @view.create.should.have.been.calledOne
      @view.create.should.have.been.calledWith @event

    it "pevents default action", ->
      @view.create @event
      @event.isDefaultPrevented().should.be.true

    context "success", ->

      beforeEach ->
        collection = new Backbone.Collection
        sinon.stub Coreon.Models.Concept, "collection", -> collection
        @view.model.url = -> ""

      afterEach ->
        Coreon.Models.Concept.collection.restore()
      
      it "accumulates newly created model", ->
        @view.create @event
        @view.model.id = "1234abcdef"
        @done()
        Coreon.Models.Concept.collection().get("1234abcdef").should.equal @view.model
        
      it "redirects to show concept page", ->
        @view.model.url = -> "concepts/1234abcdef"
        @view.create @event
        @done()
        Backbone.history.navigate.should.have.been.calledWith "concepts/1234abcdef", trigger: true

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
