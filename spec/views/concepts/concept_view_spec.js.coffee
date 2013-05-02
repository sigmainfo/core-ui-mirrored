#= require spec_helper
#= require views/concepts/concept_view
#= require models/concept

describe "Coreon.Views.Concepts.ConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    sinon.stub Coreon.Views.Concepts.Shared, "BroaderAndNarrowerView", (options) =>
      @broaderAndNarrower = new Backbone.View options
    @view = new Coreon.Views.Concepts.ConceptView
      model: new Coreon.Models.Concept
    sinon.stub Coreon.Models.Concept, "find", (id) -> new Coreon.Models.Concept _id: id

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()
    Coreon.Models.Concept.find.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.match ".concept"

  describe "initialize()", ->
  
    it "creates view for broader & narrower section", ->
      should.exist @view.broaderAndNarrower
      @view.broaderAndNarrower.should.equal @broaderAndNarrower
      @view.broaderAndNarrower.should.have.property "model", @view.model

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "is triggered by model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce
  
    it "renders label", ->
      @view.model.set "label", "Handgun", silent: true
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$("h2.label").should.have.text "Handgun"

    it "renders system info", ->
      I18n.t.withArgs("concept.info").returns "System Info"
      @view.model.id = "123"
      @view.model.set "legacy_id", "543", silent: true
      @view.render()
      @view.$el.should.have "> .system-info-toggle"
      @view.$("> .system-info-toggle").should.have.text "System Info"
      @view.$el.should.have "> .system-info"
      @view.$("> .system-info").css("display").should.equal "none"
      @view.$("> .system-info th").eq(0).should.have.text "id"
      @view.$("> .system-info td").eq(0).should.have.text "123"
      @view.$("> .system-info th").eq(1).should.have.text "legacy_id"
      @view.$("> .system-info td").eq(1).should.have.text "543"

    it "renders tree", ->
      Coreon.application = hits: new Backbone.Collection
      Coreon.application.hits.findByResult = -> null
      try
        @view.model.set "super_concept_ids", ["1234"], silent: true
        @view.initialize()
        @view.broaderAndNarrower.render = sinon.spy()
        @view.render()
        @view.broaderAndNarrower.render.should.have.been.calledOnce
        $.contains(@view.el, @view.broaderAndNarrower.el).should.be.true
      finally
        Coreon.application = null

    it "always renders tree", ->
      @view.model.set
        sub_concept_ids: []
        super_concept_ids: []
      @view.render()
      $.contains(@view.el, @view.broaderAndNarrower.el).should.be.true

    context "properties", ->

      beforeEach ->
        sinon.stub Coreon.Templates, "shared/info"
        @property = new Backbone.Model key: "label", value: "top hat"
        @property.info = -> {}
        @view.model.set "properties", [ key: "label", value: "top hat" ], silent: true
        @view.model.propertiesByKey = => label: [ @property ]

      afterEach ->
        Coreon.Templates["shared/info"].restore()
      
      it "renders section", ->
        I18n.t.withArgs("properties.title").returns "Properties"
        @view.render()
        @view.$el.should.have "section.properties"
        @view.$(".properties").should.have.match "section"
        @view.$(".properties").should.have "h3"
        @view.$(".properties h3").should.have.text "Properties"

      it "renders section only when applicable", ->
        @view.model.set "properties", [], silent: true
        @view.render()
        @view.$el.should.not.have ".properties"

      it "renders properties table", ->
        @view.model.propertiesByKey = => label: [ @property ]
        @view.render()
        @view.$(".properties").should.have "table tr"
        @view.$(".properties table tr").should.have "th"
        @view.$(".properties table th").should.have.text "label"

      it "renders simple values as plain text", ->
        @property.set "value", "top hat", silent: true
        @view.render()
        @view.$(".properties").should.have "table tr td .value"
        @view.$(".properties table td .value").should.have.text "top hat"

      it "renders system info", ->
        Coreon.Templates["shared/info"].withArgs(data: id: "1234567890").returns '<div class="system-info">id: 1234567890</div>'
        @property.info = -> id: "1234567890"
        @view.render()
        @view.$(".properties").should.have "table tr td .system-info"
        @view.$(".properties table td .system-info").should.have.text "id: 1234567890"

      it "renders multiple values in list", ->
        prop1 = new Backbone.Model value: "top hat"
        prop1.info = -> {}
        prop2 = new Backbone.Model value: "cylinder"
        prop2.info = -> {}
        @view.model.propertiesByKey = -> label: [ prop1, prop2 ]
        @view.render()
        @view.$(".properties").should.have "table tr td ul.values"
        @view.$(".properties ul.values").should.have "li"
        @view.$(".properties ul.values li").should.have.lengthOf 2
        @view.$(".properties ul.values li").eq(0).should.have.text "top hat"
        @view.$(".properties ul.values li").eq(1).should.have.text "cylinder"

      it "renders index for list", ->
        prop1 = new Backbone.Model value: "top hat"
        prop1.info = -> {}
        prop2 = new Backbone.Model value: "cylinder"
        prop2.info = -> {}
        @view.model.propertiesByKey = -> label: [ prop1, prop2 ]
        @view.render()
        @view.$(".properties").should.have "table tr td ul.index"
        @view.$(".properties ul.index").should.have "li"
        @view.$(".properties ul.index li").should.have.lengthOf 2
        @view.$(".properties ul.index li").eq(0).should.have.text "1"
        @view.$(".properties ul.index li").eq(0).should.have.attr "data-index", "0"
        @view.$(".properties ul.index li").eq(1).should.have.text "2"
        @view.$(".properties ul.index li").eq(1).should.have.attr "data-index", "1"

      it "uses lang as index when given", ->
        prop1 = new Backbone.Model value: "top hat", lang: "en"
        prop1.info = -> {}
        prop2 = new Backbone.Model value: "Zylinderhut", lang: "de"
        
        prop2.info = -> {}
        @view.model.propertiesByKey = -> label: [ prop1, prop2 ]
        @view.render()
        @view.$(".properties ul.index li").eq(0).should.have.text "en"
        @view.$(".properties ul.index li").eq(1).should.have.text "de"

      it "renders single value in list when lang is given", ->
        @property.set "lang", "de", silent: true
        @view.render()
        @view.$(".properties").should.have "table tr td ul.index"
        @view.$(".properties ul.index li").eq(0).should.have.text "de"

      it "marks first item as being selected", ->
        @view.render()
        
    context "terms", ->

      it "renders terms", ->
        @view.model.set "terms", [
          { lang: "de", value: "Puffe", properties: [] }
        ], silent: true
        @view.render()
        @view.$el.should.have ".terms"
        @view.$(".terms").should.have ".section"
        @view.$(".terms .value").should.have.text "Puffe"

      it "renders terms only when applicable", ->
        @view.model.set "terms", [], silent: true
        @view.render()
        @view.$el.should.not.have ".terms"


  describe "toggleInfo()", ->

    beforeEach ->
      @view.model.set "terms", [
        { lang: "de", value: "Puffe" }
      ], silent: true
      @view.render()
  
    it "is triggered by click on system info toggle", ->
      @view.toggleInfo = sinon.spy()
      @view.delegateEvents()
      @view.$(".system-info-toggle").click()
      @view.toggleInfo.should.have.been.calledOnce

    it "toggles system info", ->
      $("#konacha").append(@view.$el)
      @view.$(".system-info").should.be.hidden
      @view.toggleInfo()
      @view.$(".system-info").should.be.visible
      @view.toggleInfo()
      @view.$(".system-info").should.be.hidden

    it "does not toggle system info for terms", ->
      $("#konacha").append(@view.$el)
      @view.$(".terms .system-info").should.be.hidden
      @view.toggleInfo()
      @view.$(".terms .system-info").should.be.hidden


  describe "toggleSection()", ->

    beforeEach ->
      @view.$el.append """
        <section>
          <h3>PROPERTIES</h3>
          <div>foo</div>
        </section>
        """
      @event = $.Event()
    
    it "is triggered by click on caption for section", ->
      @view.toggleSection = sinon.spy()
      @view.delegateEvents()
      @view.$("section *:first-child").first().click()
      @view.toggleSection.should.have.been.calledOnce
    
    it "toggles visibility of section content", ->
      $("#konacha").append @view.$el
      @event.target = @view.$("h3").get(0)
      @view.toggleSection @event
      @view.$("section div").should.be.hidden
      @view.toggleSection @event
      @view.$("section div").should.be.visible
