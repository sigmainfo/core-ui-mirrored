#= require spec_helper
#= require views/concepts/concept_view
#= require views/concepts/concept_view

describe "Coreon.Views.Concepts.ConceptView", ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    sinon.stub I18n, "t"
    @broaderAndNarrower = new Backbone.View
    sinon.stub Coreon.Views.Concepts.Shared, "BroaderAndNarrowerView", => @broaderAndNarrower
    
    @property = new Backbone.Model key: "label", value: "top hat"
    @property.info = -> {}

    @concept = new Backbone.Model
    @concept.info = -> {}
    @concept.revert = ->
    @concept.set "properties", [ @property ], silent: true
    @concept.propertiesByKey = => label: [ @property ]

    @view = new Coreon.Views.Concepts.ConceptView
      model: @concept
    sinon.stub Coreon.Helpers, "can"
    Coreon.Helpers.can.returns true

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()
    Coreon.application = null
    Coreon.Helpers.can.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.match ".concept.show"

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
      @broaderAndNarrower.render = sinon.stub().returns @broaderAndNarrower
      @view.render()
      @broaderAndNarrower.render.should.have.been.calledOnce
      $.contains(@view.el, @broaderAndNarrower.el).should.be.true

    context "with edit privileges", ->

      beforeEach ->
        Coreon.Helpers.can.returns true

      it "renders delete concept link", ->
        I18n.t.withArgs("concept.delete").returns "Delete concept"
        @view.render()
        @view.$el.should.have ".edit a.delete-concept"
        @view.$("a.delete-concept").should.have.text "Delete concept"

      it "renders edit concept link", ->
        I18n.t.withArgs("concept.edit").returns "Edit concept"
        @view.render()
        @view.$el.should.have "a.edit-concept"
        @view.$("a.edit-concept").should.have.text "Edit concept"

    context "without edit privileges", ->

      beforeEach ->
        Coreon.Helpers.can.returns false

      it "does not render delete concept link", ->
        @view.render()
        @view.$el.should.not.have "a.delete"

      it "does not render edit concept link", ->
        @view.render()
        @view.$el.should.not.have "a.edit-concept"

    context "properties", ->

      beforeEach ->
        sinon.stub Coreon.Templates, "concepts/info"

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
        @concept.set "terms", [ lang: "de", value: "top head" ], silent: true
        @term = new Backbone.Model value: "top head" 
        @term.info = -> {}
        @concept.termsByLang = => de: [ @term ]

      afterEach ->
        Coreon.Templates["concepts/info"].restore()

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
          Coreon.Templates["concepts/properties"].withArgs(
            properties: @term.propertiesByKey(),
            collapsed: true,
            noEditButton: true
          ).returns '<ul class="properties collapsed"></ul>'
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
        @view.$(".term .properties > *:nth-child(2)").should.have.css "display", "none"

      context "with edit privileges", ->

        beforeEach ->
          Coreon.Helpers.can.returns true

        it "renders add term link", ->
          I18n.t.withArgs("term.new").returns "Add term"
          @view.render()
          @view.$(".terms").should.have ".edit a.add-term"
          @view.$(".add-term").should.have.text "Add term"

        it "renders remove term links", ->
          I18n.t.withArgs("term.delete").returns "Remove term"
          @term.id = "56789fghj"
          @view.render()
          @view.$(".term").should.have ".edit a.remove-term"
          @view.$(".term a.remove-term").should.have.text "Remove term"
          @view.$(".term a.remove-term").should.have.data "id", "56789fghj"

        it "renders edit term links", ->
          I18n.t.withArgs("term.edit").returns "Edit term"
          @term.id = "56789fghj"
          @view.render()
          @view.$(".term").should.have ".edit a.edit-term"
          @view.$(".term a.edit-term").should.have.text "Edit term"
          @view.$(".term a.edit-term").should.have.data "id", "56789fghj"

      context "without edit privileges", ->

        beforeEach ->
          Coreon.Helpers.can.returns false

        it "does not render add term link", ->
          @view.render()
          @view.$el.should.not.have ".add-term"

        it "does not render remove term link", ->
          @view.model.set "terms", [ lang: "de", value: "top head" ], silent: true
          @view.render()
          @view.$(".term").should.not.have "a.remove-term"

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
    
    it "is not triggered for section within a form", ->
      @view.toggleSection = sinon.spy()
      @view.delegateEvents()
      @view.$("section").wrap "<form>"
      @view.$("section *:first-child").first().click()
      @view.toggleSection.should.not.have.been.called

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
      @view.$el.append '''
        <table class="properties">
          <td>
            <ul class="index">
              <li data-index="0" class="selected">1</li>
              <li data-index="1">2</li>
            </ul>
            <ul class="values">
              <li class="selected">foo</li>
              <li>bar</li>
            </ul>
          </td>
        </table>
        '''
      @tab = @view.$(".index li").eq(1)

      @event = $.Event "click"
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

  describe "toggleEditMode()", ->

    beforeEach ->
      @view.editMode = no
      @view.render()

    it "is triggered by click on edit mode toggle", ->
      @view.toggleEditMode = sinon.spy()
      @view.delegateEvents()
      @view.$(".edit-concept").click()
      @view.toggleEditMode.should.have.been.calledOnce

    it "toggles edit mode value", ->
      @view.editMode.should.be.false
      @view.$(".edit-concept").click()
      @view.editMode.should.be.true

    it "rerenders the view", ->
      @view.render = sinon.spy()
      @view.delegateEvents()
      @view.$(".edit-concept").click()
      @view.render.should.have.been.calledOnce

    it "renders with show class when edit mode is off", ->
      @view.$el.should.have.class "show"
      @view.$el.should.not.have.class "edit"

    it "renders with edit class when edit mode is on", ->
      @view.toggleEditMode()
      @view.$el.should.have.class "edit"
      @view.$el.should.not.have.class "show"

  describe "toggleEditConceptProperties()", ->

    beforeEach ->
      @concept.properties = -> models: []
      @concept.persistedAttributes = -> {}
      @view.editMode = yes
      @view.editProperties = no
      @view.render()

    it "is triggered by click on edit-properties toggle", ->
      @view.toggleEditConceptProperties = sinon.spy()
      @view.delegateEvents()
      @view.$(".edit-properties").click()
      @view.toggleEditConceptProperties.should.have.been.calledOnce

    it "toggles edit properties value", ->
      @view.editProperties.should.be.false
      @view.$(".edit-properties").click()
      @view.editProperties.should.be.true

    it "rerenders the view", ->
      @view.render = sinon.spy()
      @view.delegateEvents()
      @view.$(".edit-properties").click()
      @view.render.should.have.been.calledOnce

    it "renders properties template in edit mode", ->
      @view.editMode = yes
      @view.editProperties = no
      @view.render()
      @view.$el.should.have("section.properties")
      @view.$el.should.not.have("section.edit")

    it "renders properties edit template in edit properties mode", ->
      @view.editMode = yes
      @view.editProperties = yes
      @view.render()
      @view.$el.should.have("section.properties.edit")

  describe "addTerm()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on add-term link", ->
      @view.addTerm = sinon.spy()
      @view.delegateEvents()
      @view.$(".add-term").click()
      @view.addTerm.should.have.been.calledOnce

    it "renders form", ->
      I18n.t.withArgs("term.create").returns "Create term"
      I18n.t.withArgs("form.cancel").returns "Cancel"
      @view.addTerm()
      @view.$el.should.have ".terms form.term.create"
      @view.$("form.term.create").should.have 'button[type="submit"]'
      @view.$('form.term.create button[type="submit"]').should.have.text "Create term"
      @view.$("form.term.create").should.have ".cancel"
      @view.$("form.term.create .cancel").should.have.text "Cancel"

    it "hides add-term link", ->
      I18n.t.withArgs("term.new").returns "Add term"
      $("#konacha").append @view.render().$el
      @view.addTerm()
      @view.$(".terms .edit .add-term").should.be.hidden

    it "renders inputs", ->
      I18n.t.withArgs("term.value").returns "Value"
      I18n.t.withArgs("term.lang").returns "Language"
      @view.addTerm()
      @view.$el.should.have 'form.term.create .value input'
      @view.$('form.term.create .value input').should.have.attr "required"
      @view.$el.should.have 'form.term.create .value label'
      @view.$('form.term.create .value label').should.have.text "Value"
      @view.$el.should.have 'form.term.create .lang input'
      @view.$('form.term.create .lang input').should.have.attr "required"
      @view.$el.should.have 'form.term.create .lang label'
      @view.$('form.term.create .lang label').should.have.text "Language"

    context "properties", ->

      it "renders section with title", ->
        I18n.t.withArgs("properties.title").returns "Properties"
        @view.addTerm()
        @view.$("form.term.create").should.have "section.properties"
        @view.$("form.term.create .properties").should.have "h3:first-child"
        @view.$("form.term.create .properties h3").should.have.text "Properties"

      it "renders link for adding a property", ->
        I18n.t.withArgs("properties.add").returns "Add Property"
        @view.addTerm()
        @view.$("form.term.create .properties").should.have ".edit a.add-property"
        @view.$("form.term.create .add-property").should.have.text "Add Property"
        @view.$("form.term.create .add-property").should.have.data "scope", "term[properties][]"

  describe "addProperty()", ->

    beforeEach ->
      @view.$el.append '''
        <section class="properties">
          <h3>PROPERTIES</h3>
          <div class="edit">
            <a class="add-property">Add property</a>
          </div>
        </section>
        '''
      @event = $.Event "click"
      @trigger = @view.$(".add-property")
      @event.target = @trigger[0]

    it "is triggered by click on add property link", ->
      @view.addProperty = sinon.spy()
      @view.delegateEvents()
      @view.$(".add-property").click()
      @view.addProperty.should.have.been.calledOnce

    it "inserts property inputs", ->
      @view.addProperty @event
      @view.$el.should.have ".property"

  describe "removeProperty()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers, "input", (name, attr, model, options) -> "<input />"
      @event = $.Event "click"
      @view.render()
      @view.$el.append '''
        <fieldset class="property not-persisted">
          <a class="remove-property">Remove property</a>
        </fieldset>
        '''

    afterEach ->
      Coreon.Helpers.input.restore()

    it "is triggered by click on remove action", ->
      @view.removeProperty = sinon.spy()
      @view.delegateEvents()
      @view.$(".property a.remove-property").trigger @event
      @view.removeProperty.should.have.been.calledOnce

    it "removes property input set", ->
      @event.target = @view.$(".remove-property").get(0)
      @view.removeProperty @event
      @view.$el.should.not.have ".property"

  describe "createTerm()", ->

    beforeEach ->
      @attrs = {}
      sinon.stub Coreon.Models, "Term", =>
        @term = new Backbone.Model @attrs
        @term.save = sinon.spy => @request = $.Deferred()
        @term.errors = => @errors
        @term.persistedAttributes = => @persistedAttributes
        @term
      @view.$el.append '''
        <form class="term create">
          <div class="submit">
            <button type="submit">Create term</button>
          </div>
        </form>
        '''
      @event = $.Event "submit"
      @trigger = @view.$("form")
      @event.target = @trigger[0]
      terms = new Backbone.Collection
      @view.model.terms = -> terms

    afterEach ->
      Coreon.Models.Term.restore()

    it "is triggered by submit", ->
      @view.createTerm = sinon.spy()
      @view.delegateEvents()
      @view.$("form").submit()
      @view.createTerm.should.have.been.calledOnce

    it "prevents default", ->
      @event.preventDefault = sinon.spy()
      @view.createTerm @event
      @event.preventDefault.should.have.been.calledOnce

    it "creates term", ->
      @view.model.id = "3456ghj"
      @view.createTerm @event
      Coreon.Models.Term.should.have.been.calledOnce
      Coreon.Models.Term.should.have.been.calledWithNew
      Coreon.Models.Term.should.have.been.calledWith
        concept_id: "3456ghj"
        properties: []
      @term.save.should.have.been.calledOnce
      @term.save.should.have.been.calledWith null, wait: yes

    it "notifies about success", ->
      @attrs = value: "Cowboyhut"
      I18n.t.withArgs("notifications.term.created", value: "Cowboyhut")
        .returns 'Successfully created "Cowboyhut".'
      Coreon.Models.Notification.info = sinon.spy()
      @view.createTerm @event
      @request.resolve()
      Coreon.Models.Notification.info.should.have.been.calledOnce
      Coreon.Models.Notification.info.should.have.been.calledWith 'Successfully created "Cowboyhut".'

    it "updates term from form", ->
      @view.$("form.term.create").prepend '''
        <input type="text" name="term[value]" value="high hat"/>
        <input type="text" name="term[lang]" value="en"/>
      '''
      @view.createTerm @event
      Coreon.Models.Term.firstCall.args[0].should.have.property "value", "high hat"
      Coreon.Models.Term.firstCall.args[0].should.have.property "lang", "en"

    it "cleans up properties", ->
      @view.$("form.term.create").prepend '''
        <input type="text" name="term[properties][3][key]" value="status"/>
        '''
      @view.createTerm @event
      Coreon.Models.Term.firstCall.args[0].should.have.property("properties").with.lengthOf 1
      Coreon.Models.Term.firstCall.args[0].properties[0].should.have.property "key", "status"

    it "deletes previously set properties when empty", ->
      @view.createTerm @event
      Coreon.Models.Term.firstCall.args[0].should.have.property("properties").that.eql []

    context "error", ->

      beforeEach ->
        @persistedAttributes = {}
        @errors = {}

      it "rerenders form with errors", ->
        @view.createTerm @event
        @request.reject()
        @view.$el.should.have("form.term.create")
        @view.$("form.term.create").should.have.lengthOf 1
        @view.$("form.term.create").should.have ".error-summary"

      it "renders properties within form", ->
        @view.createTerm @event
        @term.set "properties", [ key: "status" ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: "status" ]
        @request.reject()
        @view.$("form.term.create").should.have ".property"
        @view.$("form.term.create .property").should.have.lengthOf 1

      it "renders errors on properties", ->
        @view.createTerm @event
        @term.set "properties", [ key: "status" ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: "status" ]
        @term.errors = -> { nested_errors_on_properties: [ value: ["can't be blank"] ] }
        @request.reject()
        @view.$("form.term.create .property").should.have ".error-message"
        @view.$("form.term.create .property .error-message").should.have.text "can't be blank"

      it "increases index on add property link", ->
        @view.createTerm @event
        @term.set "properties", [ key: "status" ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: "status" ]
        @request.reject()
        @view.$("form.term.create .add-property").should.have.data "index", 1        

  describe "updateTerm()", ->

    beforeEach ->
      @event = $.Event "submit"
      @form = @view.$("form.term.update")
      @event.target = @form
      @view.model.terms = =>
        get: =>
          @term = new Backbone.Model
          @term.save = sinon.spy => @request = $.Deferred()
          @term

    it "prevents default", ->
      @event.preventDefault = sinon.spy()
      @view.updateTerm @event
      @event.preventDefault.should.have.been.calledOnce

    it "calls saveTerm()", ->
      @view.saveTerm = sinon.spy()
      @view.updateTerm @event
      @view.saveTerm.should.have.been.calledOnce

  describe "saveTerm()", ->

    it "notifies about update", ->
      I18n.t.withArgs("notifications.term.saved").returns "wohoow!"
      Coreon.Models.Notification.info = sinon.spy()
      model =
        save: => @request = $.Deferred()
        get: ->
      @view.saveTerm(model, {})
      @request.resolve()
      Coreon.Models.Notification.info.should.have.been.calledOnce
      Coreon.Models.Notification.info.should.have.been.calledWith "wohoow!"

  describe "cancel()", ->

    beforeEach ->
      @view.$el.append '''
        <div>
          <form class="term create">
            <div class="submit">
              <a class="cancel" href="javascript:history.back()">Cancel</a>
              <button type="submit">Create term</button>
            </div>
          </form>
          <div class="edit" style="display:none">
            <a class="add-term" ref="javascript:void(0)">Add term</a>
          </div>
        </div>
        '''
      @event = $.Event "click"
      @trigger = @view.$("form a.cancel")
      @event.target = @trigger[0]

    it "is triggered by click on cancel link", ->
      @view.cancelForm = sinon.spy()
      @view.delegateEvents()
      @trigger.click()
      @view.cancelForm.should.have.been.calledOnce

    it "is not triggered when link is disabled", ->
      @view.cancelForm = sinon.spy()
      @view.delegateEvents()
      @trigger.addClass "disabled"
      @trigger.click()
      @view.cancelForm.should.not.have.been.called

    it "prevents default action", ->
      @event.preventDefault = sinon.spy()
      @view.cancelForm @event
      @event.preventDefault.should.have.been.calledOnce

    it "removes wrapping form", ->
      @view.$el.append '''
        <form class="other"></form>
      '''
      @view.cancelForm @event
      @view.$el.should.not.have "form.term.create"
      @view.$el.should.have "form.other"

    it "shows related edit actions", ->
      $("#konacha").append @view.$el
      @view.cancelForm @event
      @view.$(".edit a.add-term").should.be.visible

  describe "reset()", ->
  
    beforeEach ->
      @view.$el.append '''
        <div>
          <form class="term create">
            <div class="submit">
              <a class="reset" href="javascript:void(0)">Reset</a>
              <button type="submit">Create term</button>
            </div>
          </form>
          <div class="edit" style="display:none">
            <a class="add-term" ref="javascript:void(0)">Add term</a>
          </div>
        </div>
        '''
      @event = $.Event "click"
      @trigger = @view.$("form a.reset")
      @event.target = @trigger[0]

    it "is triggered by click on reset link", ->
      @view.reset = sinon.spy()
      @view.delegateEvents()
      @trigger.click()
      @view.reset.should.have.been.calledOnce

    it "is not triggered when link is disabled", ->
      @view.reset = sinon.spy()
      @view.delegateEvents()
      @trigger.addClass "disabled"
      @trigger.click()
      @view.reset.should.not.have.been.called

    it "prevents default action", ->
      @event.preventDefault = sinon.spy()
      @view.reset @event
      @event.preventDefault.should.have.been.calledOnce

    it "rerenders form", ->
      @view.render = sinon.spy()
      @view.reset @event
      @view.render.should.have.been.calledOnce

    it "drops remote validation errors", ->
      @view.model.remoteError = "foo: ['must be bar']"
      @view.reset @event
      @view.model.should.have.property "remoteError", null

    it "restores previous state", ->
      @view.model.revert = sinon.spy()
      @view.reset @event
      @view.model.revert.should.have.been.calledOnce

  describe "removeTerm()", ->

    beforeEach ->
      $("#konacha")
        .append(@view.$el)
        .append '''
        <div id="coreon-modal"></div>
        '''
      @view.$el.append '''
        <li class="term">
          <div class="edit">
            <a class="remove-term" data-id="518d2569edc797ef6d000008" href="javascript:void(0)">Remove term</a>
          </divoutput>
          <h4 class="value">beaver hat</h4>
        </li>
        '''
      term = new Backbone.Model id: "518d2569edc797ef6d000008"
      term.destroy = sinon.spy()
      terms = new Backbone.Collection [ term ]
      @view.model.terms = -> terms
      @event = $.Event "click"
      @trigger = @view.$("a.remove-term")
      @event.target = @trigger[0]
      @view.confirm = sinon.spy()

    it "is triggered by click on remove term link", ->
      @view.removeTerm = sinon.spy()
      @view.delegateEvents()
      @trigger.click()
      @view.removeTerm.should.have.been.calledOnce

    it "renders confirmation dialog", ->
      I18n.t.withArgs("term.confirm_delete").returns "This term will be deleted permanently."
      @view.removeTerm @event
      @view.confirm.should.have.been.calledOnce
      options = @view.confirm.firstCall.args[0]
      options.should.have.property "message", "This term will be deleted permanently."

    it "marks term for deletetion", ->
      @view.removeTerm @event
      options = @view.confirm.firstCall.args[0]
      options.container[0].should.equal @view.$(".term")[0]

    context "destroy", ->

      beforeEach ->
        @view.removeTerm @event
        @action = @view.confirm.firstCall.args[0].action

      it "removes term from listing", ->
        li = @view.$(".term")[0]
        @action()
        $.contains(@view.$el[0], li).should.be.false

      it "destroys model", ->
        term = @view.model.terms().at 0
        @action()
        term.destroy.should.have.been.calledOnce

      it "notifies about destruction", ->
        I18n.t.withArgs("notifications.term.deleted").returns "baaam!"
        Coreon.Models.Notification.info = sinon.spy()
        @action()
        Coreon.Models.Notification.info.should.have.been.calledOnce
        Coreon.Models.Notification.info.should.have.been.calledWith "baaam!"

  describe "delete()", ->

    beforeEach ->
      $("#konacha")
        .append(@view.$el)
        .append '''
        <div id="coreon-modal"></div>
        '''
      @view.$el.append '''
        <div class="concept">
          <div class="edit">
            <a class="delete-concept" href="javascript:void(0)">Delete concept</a>
          </div>
        </div>
        '''
      @trigger = @view.$("a.delete-concept")
      @event = $.Event "click"
      @event.target = @trigger[0]
      @view.confirm = sinon.spy()

    it "is triggered by click on remove concept link", ->
      @view.delete = sinon.spy()
      @view.delegateEvents()
      @view.$(".edit .delete-concept").trigger @event
      @view.delete.should.have.been.calledOnce

    it "renders confirmation dialog", ->
      I18n.t.withArgs("concept.confirm_delete").returns "This concept will be deleted permanently."
      @view.delete @event
      @view.confirm.should.have.been.calledOnce
      options = @view.confirm.firstCall.args[0]
      options.should.have.property "message", "This concept will be deleted permanently."

    it "marks concept for deletetion", ->
      @view.delete @event
      options = @view.confirm.firstCall.args[0]
      options.container[0].should.equal @view.$(".concept")[0]

    context "confirm", ->

      beforeEach ->
        Coreon.application = repository: -> id: "8765jhgf"
        sinon.stub Backbone.history, "navigate"
        @view.delete @event
        @action = @view.confirm.firstCall.args[0].action

      afterEach ->
        Coreon.application = null
        Backbone.history.navigate.restore()

      it "redirects to repository root when done", ->
        Coreon.application = repository: -> id: "8765jhgf"
        @action()
        Backbone.history.navigate.should.have.been.calledOnce
        Backbone.history.navigate.should.have.been.calledWith "/8765jhgf", trigger: true
      
      it "destroys model", ->
        @view.model.destroy = sinon.spy()
        @action()
        @view.model.destroy.should.have.been.calledOnce

      it "notifies about destruction", ->
        I18n.t.withArgs("notifications.concept.deleted").returns "baaam!"
        Coreon.Models.Notification.info = sinon.spy()
        @action()
        Coreon.Models.Notification.info.should.have.been.calledOnce
        Coreon.Models.Notification.info.should.have.been.calledWith "baaam!"

  describe "clipboard interaction", ->

    beforeEach ->
      @collection = new Backbone.Collection
      sinon.stub Coreon.Collections.Clips, "collection", => @collection
      sinon.spy @view, "setClipboardButton"

    afterEach ->
      Coreon.Collections.Clips.collection.restore()
      @view.setClipboardButton.restore()

    it "sets button if clips changing", ->
      @view.initialize()
      @collection.add @concept
      @collection.reset []
      @view.setClipboardButton.should.have.been.calledTwice
