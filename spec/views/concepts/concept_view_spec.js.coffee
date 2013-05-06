#= require spec_helper
#= require views/concepts/concept_view

describe "Coreon.Views.Concepts.ConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    sinon.stub Coreon.Views.Concepts.Shared, "BroaderAndNarrowerView", (options) =>
      @broaderAndNarrower = new Backbone.View options
    @concept = new Backbone.Model
    @concept.info = -> {}
    @view = new Coreon.Views.Concepts.ConceptView
      model: @concept

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.match ".concept.show"

  describe "initialize()", ->
  
    it "creates view for broader & narrower section", ->
      should.exist @view.broaderAndNarrower
      @view.broaderAndNarrower.should.equal @broaderAndNarrower
      @view.broaderAndNarrower.should.have.property "model", @concept

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "is triggered by model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @concept.trigger "change"
      @view.render.should.have.been.calledOnce
  
    it "renders label", ->
      @concept.set "label", "Handgun", silent: true
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$("h2.label").should.have.text "Handgun"

    it "renders system info", ->
      I18n.t.withArgs("concept.info").returns "System Info"
      @concept.info = ->
        id: "123"
        legacy_id: "543"
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
        @concept.set "super_concept_ids", ["1234"], silent: true
        @view.initialize()
        @view.broaderAndNarrower.render = sinon.spy()
        @view.render()
        @view.broaderAndNarrower.render.should.have.been.calledOnce
        $.contains(@view.el, @view.broaderAndNarrower.el).should.be.true
      finally
        Coreon.application = null

    it "always renders tree", ->
      @concept.set
        sub_concept_ids: []
        super_concept_ids: []
      @view.render()
      $.contains(@view.el, @view.broaderAndNarrower.el).should.be.true

    context "properties", ->

      beforeEach ->
        sinon.stub Coreon.Templates, "concepts/info"
        @property = new Backbone.Model key: "label", value: "top hat"
        @property.info = -> {}
        @concept.set "properties", [ key: "label", value: "top hat" ], silent: true
        @concept.propertiesByKey = => label: [ @property ]

      afterEach ->
        Coreon.Templates["concepts/info"].restore()
      
      it "renders section", ->
        I18n.t.withArgs("properties.title").returns "Properties"
        @view.render()
        @view.$el.should.have "section.properties"
        @view.$(".properties").should.have.match "section"
        @view.$(".properties").should.have "h3"
        @view.$(".properties h3").should.have.text "Properties"

      it "renders section only when applicable", ->
        @concept.set "properties", [], silent: true
        @view.render()
        @view.$el.should.not.have ".properties"

      it "renders properties table", ->
        @concept.propertiesByKey = => label: [ @property ]
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
        Coreon.Templates["concepts/info"].withArgs(data: id: "1234567890")
          .returns '<div class="system-info">id: 1234567890</div>'
        @property.info = -> id: "1234567890"
        @view.render()
        @view.$(".properties").should.have "table tr td .system-info"
        @view.$(".properties table td .system-info").should.have.text "id: 1234567890"

      it "renders multiple values in list", ->
        prop1 = new Backbone.Model value: "top hat"
        prop1.info = -> {}
        prop2 = new Backbone.Model value: "cylinder"
        prop2.info = -> {}
        @concept.propertiesByKey = -> label: [ prop1, prop2 ]
        @view.render()
        @view.$(".properties").should.have "table tr td ul.values"
        @view.$(".properties ul.values").should.have "li .value"
        @view.$(".properties ul.values li .value").should.have.lengthOf 2
        @view.$(".properties ul.values li .value").eq(0).should.have.text "top hat"
        @view.$(".properties ul.values li .value").eq(1).should.have.text "cylinder"

      it "renders index for list", ->
        prop1 = new Backbone.Model value: "top hat"
        prop1.info = -> {}
        prop2 = new Backbone.Model value: "cylinder"
        prop2.info = -> {}
        @concept.propertiesByKey = -> label: [ prop1, prop2 ]
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
        @concept.propertiesByKey = -> label: [ prop1, prop2 ]
        @view.render()
        @view.$(".properties ul.index li").eq(0).should.have.text "en"
        @view.$(".properties ul.index li").eq(1).should.have.text "de"

      it "renders single value in list when lang is given", ->
        @property.set "lang", "de", silent: true
        @view.render()
        @view.$(".properties").should.have "table tr td ul.index"
        @view.$(".properties ul.index li").eq(0).should.have.text "de"

      it "renders system info in list", ->
        Coreon.Templates["concepts/info"].withArgs(data: id: "1234567890")
          .returns '<div class="system-info">id: 1234567890</div>'
        @property.set "lang", "de", silent: true
        @property.info = -> id: "1234567890"
        @view.render()
        @view.$(".properties .values li").should.have ".system-info"

      it "marks first item as being selected", ->
        prop1 = new Backbone.Model value: "top hat"
        prop1.info = -> {}
        prop2 = new Backbone.Model value: "cylinder"
        prop2.info = -> {}
        @concept.propertiesByKey = -> label: [ prop1, prop2 ]
        @view.render()
        @view.$(".properties ul.index li").eq(0).should.have.class "selected"
        @view.$(".properties ul.values li").eq(0).should.have.class "selected"
        @view.$(".properties ul.index li").eq(1).should.not.have.class "selected"
        @view.$(".properties ul.values li").eq(1).should.not.have.class "selected"

    context "terms", ->

      beforeEach ->
        sinon.stub Coreon.Templates, "concepts/info"

      afterEach ->
        Coreon.Templates["concepts/info"].restore()

      beforeEach ->
        @concept.set "terms", [ lang: "de", value: "top head" ], silent: true
        @term = new Backbone.Model value: "top head" 
        @term.info = -> {}
        @concept.termsByLang = => de: [ @term ]

      it "renders container", ->
        @view.render()
        @view.$el.should.have ".terms"

      it "renders section for languages", ->
        term1 = new Backbone.Model
        term1.info = -> {}
        term2 = new Backbone.Model
        term2.info = -> {}
        @concept.termsByLang = ->
          de: [ term1 ]
          en: [ term2 ]
        @view.render()
        @view.$el.should.have ".terms section.language"
        @view.$("section.language").should.have.lengthOf 2
        @view.$("section.language").eq(0).should.have.class "de"
        @view.$("section.language").eq(1).should.have.class "en"

      it "renders caption for language", ->
        @concept.termsByLang = => hu: [ @term ]
        @view.render()
        @view.$(".language").should.have "h3"
        @view.$(".language h3").should.have.text "hu"

      it "renders terms", ->
        @term.set "value", "top hat", silent: true
        @concept.termsByLang = => hu: [ @term ]
        @view.render()
        @view.$(".language").should.have ".term"
        @view.$(".term").should.have ".value"
        @view.$(".term .value").should.have.text "top hat"

      it "renders system info for of term", ->
        @term.info = -> id: "#1234"
        Coreon.Templates["concepts/info"].withArgs(data: id: "#1234")
          .returns '<div class="system-info">id: #1234</div>'
        @view.render()
        @view.$(".term").should.have ".system-info"

      it "renders term properties", ->
        @term.set "properties", [ source: "Wikipedia" ], silent: true
        property = new Backbone.Model source: "Wikipedia" 
        @term.propertiesByKey = -> source: [ property ]
        sinon.stub Coreon.Templates, "concepts/properties"
        try
          Coreon.Templates["concepts/properties"].withArgs(collapsed: true, properties: source: [ property ])
            .returns '<ul class="properties collapsed"></ul>'
          @view.render()
          @view.$(".term").should.have ".properties"
        finally
          Coreon.Templates["concepts/properties"].restore()
        
      it "collapses properties by default", ->
        @term.set "properties", [ source: "Wikipedia" ], silent: true
        property = new Backbone.Model source: "Wikipedia"
        property.info = -> {}
        @term.propertiesByKey = -> source: [ property ]
        @view.render()
        @view.$(".term .properties").should.have.class "collapsed"
        @view.$(".term .properties table").should.have.css "display", "none"

  describe "toggleInfo()", ->

    beforeEach ->
      @view.$el.append """
        <section>
          <h3 class="system-info-toggle" id="outer-trigger">INFO</h3>
          <div class="system-info">foo</div>
          <ul class="properties">
            <div class="system-info">bar</div>
          </ul>
          <div class="terms">
            <h3 class="system-info-toggle" id="inner-trigger">INFO</h3>
            <div class="system-info">baz</div>
            <ul class="properties">
              <div class="system-info">bar</div>
            </ul>
          </div>
        </section>
        """
      @event = $.Event()
      $("#konacha").append @view.$el
  
    it "is triggered by click on system info toggle", ->
      @view.toggleInfo = sinon.spy()
      @view.delegateEvents()
      @view.$("#outer-trigger").click()
      @view.toggleInfo.should.have.been.calledOnce

    it "toggles outer system info", ->
      @event.target = @view.$ "#outer-trigger"
      @view.toggleInfo @event
      @view.$("section > .system-info").should.be.hidden
      @view.$("section .properties .system-info").should.be.hidden
      @view.$("section .terms .system-info").should.be.visible
      @view.$("section .terms .properties .system-info").should.be.visible
      @view.toggleInfo @event
      @view.$("section > .system-info").should.be.visible
      @view.$("section .properties .system-info").should.be.visible
      @view.$("section .terms .system-info").should.be.visible
      @view.$("section .terms .properties .system-info").should.be.visible

    it "toggles inner system info", ->
      @event.target = @view.$ "#inner-trigger"
      @view.toggleInfo @event
      @view.$("section .terms .system-info").should.be.hidden
      @view.$("section .terms .properties .system-info").should.be.hidden
      @view.$("section > .system-info").should.be.visible
      @view.$("section .properties .system-info").should.be.visible
      @view.toggleInfo @event
      @view.$("section .terms .system-info").should.be.visible
      @view.$("section .terms .properties .system-info").should.be.visible
      @view.$("section > .system-info").should.be.visible
      @view.$("section .properties .system-info").should.be.visible

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

    it "toggles state of section", ->
      @event.target = @view.$("h3").get(0)
      @view.toggleSection @event
      @view.$("section").should.have.class "collapsed"
      @view.toggleSection @event
      @view.$("section").should.not.have.class "collapsed"

  describe "selectProperty()", ->

    beforeEach ->
      @event = $.Event "click"
      @view.$el.append '''
        <div class="properties">
            <ul class="index">
              <li data-index="0" class="selected">1</li>
              <li data-index="1">2</li>
            </ul>
            <ul class="values">
              <li class="selected">foo</li>
              <li>bar</li>
            </ul>
        </div>
        '''
      @tab = @view.$(".index li").eq(1)
      @event.target = @tab[0]

    it "is triggered by click on selector", ->
      @view.selectProperty = sinon.spy()
      @view.delegateEvents()
      @tab.trigger @event
      @view.selectProperty.should.have.been.calledOnce
      @view.selectProperty.should.have.been.calledWith @event

    it "updates selection", ->
      @view.selectProperty @event
      @view.$(".index li").eq(1).should.have.class "selected"
      @view.$(".index li").eq(0).should.not.have.class "selected"
      @view.$(".values li").eq(1).should.have.class "selected"
      @view.$(".values li").eq(0).should.not.have.class "selected"

