#= require spec_helper
#= require views/concepts/concept_view

describe 'Coreon.Views.Concepts.ConceptView', ->

  TermsView = null

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.application.repositorySettings = ->
    Coreon.application.langs = -> []
    Coreon.application.sourceLang = -> 'none'
    Coreon.application.targetLang = -> 'none'
    sinon.stub I18n, 't'
    @broaderAndNarrower = new Backbone.View
    sinon.stub Coreon.Views.Concepts.Shared, 'BroaderAndNarrowerView', => @broaderAndNarrower

    termsView = new Backbone.View
    sinon.stub Coreon.Views.Terms, 'TermsView'
    Coreon.Views.Terms.TermsView.returns termsView

    @property = new Backbone.Model key: 'label', value: 'top hat'
    @property.info = -> {}

    @concept = new Backbone.Model
    @concept.info = -> {}
    @concept.revert = ->
    @concept.set 'properties', [ @property ], silent: true
    @concept.termsByLang = -> {}
    terms = new Backbone.Collection
    terms.hasProperties = -> no
    @concept.terms = -> terms
    @concept.propertiesByKeyAndLang = => label: [ @property ]

    @view = new Coreon.Views.Concepts.ConceptView
      model: @concept
    sinon.stub Coreon.Helpers, 'can'
    Coreon.Helpers.can.returns true

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()
    Coreon.Views.Terms.TermsView.restore()
    Coreon.application = null
    Coreon.Helpers.can.restore()

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.match '.concept'

  describe '#render()', ->

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'is triggered by model change', ->
      @view.render = sinon.spy()
      @view.initialize()
      @concept.trigger 'change'
      expect( @view.render ).to.have.been.calledOnce

    it 'is triggered by edit mode change', ->
      @view.render = sinon.spy()
      @view.initialize()
      Coreon.application.trigger 'change:editing'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    it 'renders label', ->
      @concept.set 'label', 'Handgun', silent: true
      @view.render()
      expect( @view.$el ).to.have 'h2.label'
      expect( @view.$('h2.label') ).to.have.text 'Handgun'

    it 'renders system info', ->
      I18n.t.withArgs('concept.info.label').returns 'System Info'
      @concept.info = ->
        id: '123'
        legacy_id: '543'
      @view.render()
      expect( @view.$el ).to.have "> .concept-head .actions .system-info-toggle"
      expect( @view.$("> .concept-head .actions .system-info-toggle") ).to.have.text "System Info"
      expect( @view.$el ).to.have "> .concept-head .system-info"
      expect( @view.$("> .concept-head .system-info th").eq(0) ).to.have.text "id"
      expect( @view.$("> .concept-head .system-info td").eq(0) ).to.have.text "123"
      expect( @view.$("> .concept-head .system-info th").eq(1) ).to.have.text "legacy_id"
      expect( @view.$("> .concept-head .system-info td").eq(1) ).to.have.text "543"

    it 'renders tree', ->
      @broaderAndNarrower.render = sinon.stub().returns @broaderAndNarrower
      @view.render()
      expect( @broaderAndNarrower.render ).to.have.been.calledOnce
      expect( $.contains(@view.el, @broaderAndNarrower.el) ).to.be.true

    it 'hides all system info', ->
      @concept.info = -> import_id: '123'
      @view.render()
      info = @view.$('.system-info')
      expect(info).to.have.css 'display', 'none'

    context 'edit mode off', ->

      beforeEach ->
        Coreon.application.set 'editing', off, silent: yes

      it 'classifies el', ->
        @view.render()
        expect( @view.$el ).to.have.class 'show'
        expect( @view.$el ).to.not.have.class 'edit'

    context 'edit mode on', ->

      beforeEach ->
        Coreon.application.set 'editing', on, silent: yes

      it 'classifies el', ->
        @view.render()
        expect( @view.$el ).to.have.class 'edit'
        expect( @view.$el ).to.not.have.class 'show'

    context 'properties', ->

      beforeEach ->
        sinon.stub Coreon.Templates, 'concepts/info'

      afterEach ->
        Coreon.Templates['concepts/info'].restore()

      it 'renders section', ->
        I18n.t.withArgs('properties.title').returns 'Properties'
        @view.render()
        expect( @view.$el ).to.have 'section.properties'
        expect( @view.$('.properties') ).to.have.match 'section'
        expect( @view.$('.properties') ).to.have 'h3'
        expect( @view.$('.properties h3') ).to.have.text 'Properties'

      it 'renders section only when applicable', ->
        @concept.set 'properties', [], silent: true
        @view.render()
        expect( @view.$el ).to.not.have '.properties'

      it 'renders properties table', ->
        @concept.propertiesByKeyAndLang = => label: [ @property ]
        @view.render()
        expect( @view.$('.properties') ).to.have 'table tr'
        expect( @view.$('.properties table tr') ).to.have 'th'
        expect( @view.$('.properties table th') ).to.have.text 'label'

      it 'renders simple values as plain text', ->
        @property.set 'value', 'top hat', silent: true
        @view.render()
        expect( @view.$('.properties') ).to.have 'table tr td .value'
        expect( @view.$('.properties table td .value') ).to.have.text 'top hat'

      it 'renders system info', ->
        Coreon.Templates['concepts/info'].withArgs(data: id: '1234567890')
          .returns '<div class="system-info">id: 1234567890</div>'
        @property.info = -> id: '1234567890'
        @view.render()
        expect( @view.$('.properties') ).to.have 'table tr td .system-info'
        expect( @view.$('.properties table td .system-info') ).to.have.text 'id: 1234567890'

      it 'renders multiple values in list', ->
        prop1 = new Backbone.Model value: 'top hat'
        prop1.info = -> {}
        prop2 = new Backbone.Model value: 'cylinder'
        prop2.info = -> {}
        @concept.propertiesByKeyAndLang = -> label: [ prop1, prop2 ]
        @view.render()
        expect( @view.$('.properties') ).to.have 'table tr td ul.values'
        expect( @view.$('.properties ul.values') ).to.have 'li .value'
        expect( @view.$('.properties ul.values li .value') ).to.have.lengthOf 2
        expect( @view.$('.properties ul.values li .value').eq(0) ).to.have.text 'top hat'
        expect( @view.$('.properties ul.values li .value').eq(1) ).to.have.text 'cylinder'

      it 'renders index for list', ->
        prop1 = new Backbone.Model value: 'top hat'
        prop1.info = -> {}
        prop2 = new Backbone.Model value: 'cylinder'
        prop2.info = -> {}
        @concept.propertiesByKeyAndLang = -> label: [ prop1, prop2 ]
        @view.render()
        expect( @view.$('.properties') ).to.have 'table tr td ul.index'
        expect( @view.$('.properties ul.index') ).to.have 'li'
        expect( @view.$('.properties ul.index li') ).to.have.lengthOf 2
        expect( @view.$('.properties ul.index li').eq(0) ).to.have.text '1'
        expect( @view.$('.properties ul.index li').eq(0) ).to.have.attr 'data-index', '0'
        expect( @view.$('.properties ul.index li').eq(1) ).to.have.text '2'
        expect( @view.$('.properties ul.index li').eq(1) ).to.have.attr 'data-index', '1'

      it 'uses lang as index when given', ->
        prop1 = new Backbone.Model value: 'top hat', lang: 'en'
        prop1.info = -> {}
        prop2 = new Backbone.Model value: 'Zylinderhut', lang: 'de'

        prop2.info = -> {}
        @concept.propertiesByKeyAndLang = -> label: [ prop1, prop2 ]
        @view.render()
        expect( @view.$('.properties ul.index li').eq(0) ).to.have.text 'en'
        expect( @view.$('.properties ul.index li').eq(1) ).to.have.text 'de'

      it 'renders single value in list when lang is given', ->
        @property.set 'lang', 'de', silent: true
        @view.render()
        expect( @view.$('.properties') ).to.have 'table tr td ul.index'
        expect( @view.$('.properties ul.index li').eq(0) ).to.have.text 'de'

      it 'renders system info in list', ->
        Coreon.Templates['concepts/info'].withArgs(data: id: '1234567890')
          .returns '<div class="system-info">id: 1234567890</div>'
        @property.set 'lang', 'de', silent: true
        @property.info = -> id: '1234567890'
        @view.render()
        expect( @view.$('.properties .values li') ).to.have '.system-info'

      it 'marks first item as being selected', ->
        prop1 = new Backbone.Model value: 'top hat'
        prop1.info = -> {}
        prop2 = new Backbone.Model value: 'cylinder'
        prop2.info = -> {}
        @concept.propertiesByKeyAndLang = -> label: [ prop1, prop2 ]
        @view.render()
        expect( @view.$('.properties ul.index li').eq(0) ).to.have.class 'selected'
        expect( @view.$('.properties ul.values li').eq(0) ).to.have.class 'selected'
        expect( @view.$('.properties ul.index li').eq(1) ).to.not.have.class 'selected'
        expect( @view.$('.properties ul.values li').eq(1) ).to.not.have.class 'selected'

    context 'terms', ->

      terms = null

      beforeEach ->
        terms = new Backbone.Collection
        terms.hasProperties = -> no
        @concept.terms = -> terms

      it 'creates subview instance', ->
        subview = new Backbone.View
        constructor = Coreon.Views.Terms.TermsView
        constructor.withArgs(model: terms).returns subview
        @view.render()
        expect(constructor).to.have.been.calledOnce
        subviews = @view.subviews
        expect(subviews).to.include subview

      it 'renders subview', ->
        subview = new Backbone.View
        render = sinon.stub()
        render.returns subview
        subview.render = render
        constructor = Coreon.Views.Terms.TermsView
        constructor.returns subview
        @view.render()
        expect(render).to.have.been.calledOnce
        el = @view.el
        node = subview.el
        expect($.contains el, node).to.be.true

      context 'editing', ->

        beforeEach ->
          Coreon.application.set 'editing', on, silent: yes
          sinon.stub Coreon.Templates, 'concepts/info'
          @concept.set 'terms', [ lang: 'de', value: 'top head' ], silent: true
          @term = new Backbone.Model value: 'top head'
          @term.info = -> {}
          @term.properties = -> new Backbone.Collection
          @term.propertiesByKey = -> []
          @concept.termsByLang = => de: [ @term ]
          Coreon.application.langs = -> [ 'de' ]

        afterEach ->
          Coreon.Templates['concepts/info'].restore()

        it 'renders container', ->
          @view.render()
          expect( @view.$el ).to.have '.terms'

        it 'renders section for languages', ->
          term1 = new Backbone.Model
          term1.info = -> {}
          term1.propertiesByKey = -> []
          term2 = new Backbone.Model
          term2.info = -> {}
          term2.propertiesByKey = -> []
          Coreon.application.langs = -> [ 'de', 'en', 'hu' ]
          @concept.termsByLang = ->
            de: [ term1 ]
            en: [ term2 ]
          @view.render()
          expect( @view.$el ).to.have '.terms section.language'
          expect( @view.$('section.language') ).to.have.lengthOf 2
          expect( @view.$('section.language').eq(0) ).to.have.class 'de'
          expect( @view.$('section.language').eq(1) ).to.have.class 'en'

        it 'renders caption for language', ->
          @concept.termsByLang = => de: [ @term ]
          @view.render()
          expect( @view.$('.language') ).to.have 'h3'
          expect( @view.$('.language h3') ).to.have.text 'de'

        it 'renders terms', ->
          @term.set 'value', 'top hat', silent: true
          @concept.termsByLang = => de: [ @term ]
          @view.render()
          expect( @view.$('.language') ).to.have '.term'
          expect( @view.$('.term') ).to.have '.value'
          expect( @view.$('.term .value') ).to.have.text 'top hat'

        it 'renders placeholder text when terms in source lang are empty', ->
          I18n.t.withArgs('terms.empty').returns 'No terms for this language'
          Coreon.application.sourceLang = -> 'de'
          Coreon.application.langs = -> ['de', 'hu', 'en']
          @concept.termsByLang = => {}
          @view.render()
          expect( @view.$('.language.de') ).to.not.have '.term'
          expect( @view.$('.language.de') ).to.have '.no-terms'
          expect( @view.$('.de .no-terms') ).to.have.text 'No terms for this language'

        it 'renders placeholder text when terms in target lang are empty', ->
          I18n.t.withArgs('terms.empty').returns 'No terms for this language'
          Coreon.application.targetLang = -> 'hu'
          Coreon.application.langs = -> ['de', 'hu', 'en']
          @concept.termsByLang = => {}
          @view.render()
          expect( @view.$('.language.hu') ).to.not.have '.term'
          expect( @view.$('.language.hu') ).to.have '.no-terms'
          expect( @view.$('.hu .no-terms') ).to.have.text 'No terms for this language'

        it 'renders unknown langs', ->
          @term.set 'value', 'foo', silent: true
          Coreon.application.langs = -> ['de', 'hu', 'en']
          @concept.termsByLang = => ko: [ @term ]
          @view.render()
          expect( @view.$('.language.ko') ).to.exist
          expect( @view.$('.language.ko') ).to.have '.term'
          expect( @view.$('.ko .term .value') ).to.have.text 'foo'

        it 'renders system info for of term', ->
          @term.info = -> id: '#1234'
          Coreon.Templates['concepts/info'].withArgs(data: id: '#1234')
            .returns '<div class="system-info">id: #1234</div>'
          @view.render()
          expect( @view.$('.term') ).to.have '.system-info'

        context 'term properties', ->

          properties = null

          beforeEach ->
            property = new Backbone.Model key: 'source', value: 'Wikipedia'
            property.info = -> {}
            properties = [ key: 'source', properties: [ property ] ]
            @term.propertiesByKey = -> properties
            terms = new Backbone.Collection [@term]
            terms.hasProperties = -> no
            @concept.terms = -> terms

          it 'renders term properties', ->
            @view.render()
            expect( @view.$('.term') ).to.have '.properties'

          it 'collapses properties by default', ->
            @view.render()
            expect( @view.$('.term .properties') ).to.have.class 'collapsed'
            expect( @view.$('.term .properties > *:nth-child(2)') ).to.have.css 'display', 'none'

          it 'renders toggle for properties', ->
            I18n.t.withArgs('terms.properties.toggle.hint').returns 'Toggle properties'
            @view.render()
            expect( @view.$('.term .properties h3') ).to.have.attr 'title', 'Toggle properties'

          it 'renders toggle all button', ->
            I18n.t.withArgs('terms.properties.toggle-all.hint').returns 'Toggle all properties'
            terms.hasProperties = -> yes
            @view.render()
            expect( @view.$('.terms') ).to.have '> .properties-toggle'
            toggle = @view.$('.terms > .properties-toggle')
            expect( toggle ).to.have.attr 'title', 'Toggle all properties'

          it 'renders toggle button only when applicable', ->
            @term.propertiesByKeyAndLang = -> {}
            terms.hasProperties = -> no
            @view.render()
            expect( @view.$('.terms') ).to.not.have '.properties-toggle'

        context 'with edit privileges', ->

          beforeEach ->
            Coreon.Helpers.can.returns true

          it 'renders add term link', ->
            I18n.t.withArgs('term.new').returns 'Add term'
            @view.render()
            expect( @view.$('.terms') ).to.have '.edit a.add-term'
            expect( @view.$('.add-term') ).to.have.text 'Add term'

          it 'renders remove term links', ->
            I18n.t.withArgs('term.delete').returns 'Remove term'
            @term.id = '56789fghj'
            @view.render()
            expect( @view.$('.term') ).to.have '.edit a.remove-term'
            expect( @view.$('.term a.remove-term') ).to.have.text 'Remove term'
            expect( @view.$('.term a.remove-term') ).to.have.data 'id', '56789fghj'

          it 'renders edit term links', ->
            I18n.t.withArgs('term.edit.label').returns 'Edit term'
            @term.id = '56789fghj'
            @view.render()
            expect( @view.$('.term') ).to.have '.edit a.edit-term'
            expect( @view.$('.term a.edit-term') ).to.have.text 'Edit term'
            expect( @view.$('.term a.edit-term') ).to.have.data 'id', '56789fghj'

        context 'without edit privileges', ->

          beforeEach ->
            Coreon.Helpers.can.returns false

          it 'does not render add term link', ->
            @view.render()
            expect( @view.$el ).to.not.have '.add-term'

          it 'does not render remove term link', ->
            @view.model.set 'terms', [ lang: 'de', value: 'top head' ], silent: true
            @view.render()
            expect( @view.$('.term') ).to.not.have 'a.remove-term'

  describe '#toggleInfo()', ->

    beforeEach ->
      @view.$el.append """
        <section>
          <div class="actions">
            <h3 class="system-info-toggle">INFO</h3>
          </div>
          <div class="system-info">foo</div>
        </section>
      """
      $("#konacha").append @view.$el

    it "is triggered by click on system info toggle", ->
      @view.toggleInfo = sinon.spy()
      @view.delegateEvents()
      @view.$(".system-info-toggle").click()
      expect( @view.toggleInfo ).to.have.been.calledOnce

    it "toggles system info", ->
      @view.toggleInfo()
      expect( @view.$(".system-info") ).to.be.hidden
      @view.toggleInfo()
      expect( @view.$(".system-info") ).to.be.visible

  describe "toggleSection()", ->

    beforeEach ->
      @view.$el.append """
        <section>
          <h3>PROPERTIES</h3>
          <div>foo</div>
        </section>
        """
      @event = $.Event()

    it 'is triggered by click on caption for section', ->
      @view.toggleSection = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('section *:first-child').first().click()
      expect( @view.toggleSection ).to.have.been.calledOnce

    it 'is not triggered for section within a form', ->
      @view.toggleSection = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('section').wrap '<form>'
      @view.$('section *:first-child').first().click()
      expect( @view.toggleSection ).to.not.have.been.called

    it 'toggles visibility of section content', ->
      $('#konacha').append @view.$el
      @event.target = @view.$('h3').get(0)
      @view.toggleSection @event
      expect( @view.$('section div') ).to.be.hidden
      @view.toggleSection @event
      expect( @view.$('section div') ).to.be.visible

    it 'toggles state of section', ->
      @event.target = @view.$('h3').get(0)
      @view.toggleSection @event
      expect( @view.$('section') ).to.have.class 'collapsed'
      @view.toggleSection @event
      expect( @view.$('section') ).to.not.have.class 'collapsed'

  describe '#selectProperty()', ->

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
      @tab = @view.$('.index li').eq(1)

      @event = $.Event 'click'
      @event.target = @tab[0]

    it 'is triggered by click on selector', ->
      @view.selectProperty = sinon.stub().returns false
      @view.delegateEvents()
      @tab.trigger @event
      expect( @view.selectProperty ).to.have.been.calledOnce
      expect( @view.selectProperty ).to.have.been.calledWith @event

    it 'updates selection', ->
      @view.selectProperty @event
      expect( @view.$('.index li').eq(1) ).to.have.class 'selected'
      expect( @view.$('.index li').eq(0) ).to.not.have.class 'selected'
      expect( @view.$('.values li').eq(1) ).to.have.class 'selected'
      expect( @view.$('.values li').eq(0) ).to.not.have.class 'selected'

  describe '#toggleEditMode()', ->

    toggle = null
    event = null

    beforeEach ->
      @view.$el.html '<a class="toggle-edit-mode">Edit mode</a>'
      toggle = @view.$('.toggle-edit-mode')
      event = $.Event 'click'
      event.target = toggle[0]

    it 'is triggered by click on edit mode toggle', ->
      toggleEditMode = sinon.stub @view, 'toggleEditMode'
      @view.delegateEvents()
      toggle.trigger event
      expect(toggleEditMode).to.have.been.calledOnce

    it 'toggles edit mode from off to on', ->
      Coreon.application.set 'editing', off, silent: yes
      @view.toggleEditMode event
      expect(Coreon.application.get 'editing').to.be.true

    it 'toggles edit mode from on to off', ->
      Coreon.application.set 'editing', on, silent: yes
      @view.toggleEditMode event
      expect(Coreon.application.get 'editing').to.be.false

  describe '#toggleEditConceptProperties()', ->

    beforeEach ->
      @concept.properties = -> models: []
      @concept.persistedAttributes = -> {}
      Coreon.application.set 'editing', on, silent: yes
      @view.editProperties = no
      @view.render()

    it 'is triggered by click on edit-properties toggle', ->
      @view.toggleEditConceptProperties = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.edit-properties').click()
      expect( @view.toggleEditConceptProperties ).to.have.been.calledOnce

    it 'toggles edit properties value', ->
      expect( @view.editProperties ).to.be.false
      @view.$('.edit-properties').click()
      expect( @view.editProperties ).to.be.true

    it 'rerenders the view', ->
      @view.render = sinon.spy()
      @view.delegateEvents()
      @view.$('.edit-properties').click()
      expect( @view.render ).to.have.been.calledOnce

    it 'renders properties template in edit mode', ->
      @view.editing = yes
      @view.editProperties = no
      @view.render()
      expect( @view.$el ).to.have('section.properties')
      expect( @view.$el ).to.not.have('section.edit')

    it 'renders properties edit template in edit properties mode', ->
      @view.editing = yes
      @view.editProperties = yes
      @view.render()
      expect( @view.$el ).to.have('section.properties.edit')

  describe '#addTerm()', ->

    beforeEach ->
      Coreon.application.set 'editing', on, silent: yes
      @view.render()

    it 'is triggered by click on add-term link', ->
      @view.addTerm = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.add-term').click()
      expect( @view.addTerm ).to.have.been.calledOnce

    it 'renders form', ->
      I18n.t.withArgs('term.create').returns 'Create term'
      I18n.t.withArgs('form.cancel').returns 'Cancel'
      @view.addTerm()
      expect( @view.$el ).to.have '.terms form.term.create'
      expect( @view.$('form.term.create') ).to.have 'button[type="submit"]'
      expect( @view.$('form.term.create button[type="submit"]') ).to.have.text 'Create term'
      expect( @view.$('form.term.create') ).to.have '.cancel'
      expect( @view.$('form.term.create .cancel') ).to.have.text 'Cancel'

    it 'hides add-term link', ->
      I18n.t.withArgs('term.new').returns 'Add term'
      $('#konacha').append @view.render().$el
      @view.addTerm()
      expect( @view.$('.terms .edit .add-term') ).to.be.hidden

    it 'renders inputs', ->
      I18n.t.withArgs('term.value').returns 'Value'
      I18n.t.withArgs('term.lang').returns 'Language'
      @view.addTerm()
      expect( @view.$el ).to.have 'form.term.create .value input'
      expect( @view.$('form.term.create .value input') ).to.have.attr 'required'
      expect( @view.$el ).to.have 'form.term.create .value label'
      expect( @view.$('form.term.create .value label') ).to.have.text 'Value'
      expect( @view.$el ).to.have 'form.term.create .lang input'
      expect( @view.$('form.term.create .lang input') ).to.have.attr 'required'
      expect( @view.$el ).to.have 'form.term.create .lang label'
      expect( @view.$('form.term.create .lang label') ).to.have.text 'Language'

    context 'properties', ->

      it 'renders section with title', ->
        I18n.t.withArgs('properties.title').returns 'Properties'
        @view.addTerm()
        expect( @view.$('form.term.create') ).to.have 'section.properties'
        expect( @view.$('form.term.create .properties') ).to.have 'h3:first-child'
        expect( @view.$('form.term.create .properties h3') ).to.have.text 'Properties'

      it 'renders link for adding a property', ->
        I18n.t.withArgs('properties.add').returns 'Add Property'
        @view.addTerm()
        expect( @view.$('form.term.create .properties') ).to.have '.edit a.add-property'
        expect( @view.$('form.term.create .add-property') ).to.have.text 'Add Property'
        expect( @view.$('form.term.create .add-property') ).to.have.data 'scope', 'term[properties][]'

  describe '#addProperty()', ->

    beforeEach ->
      @view.$el.append '''
        <section class="properties">
          <h3>PROPERTIES</h3>
          <div class="edit">
            <a class="add-property">Add property</a>
          </div>
        </section>
        '''
      @event = $.Event 'click'
      @trigger = @view.$('.add-property')
      @event.target = @trigger[0]

    it 'is triggered by click on add property link', ->
      @view.addProperty = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.add-property').click()
      expect( @view.addProperty ).to.have.been.calledOnce

    it 'inserts property inputs', ->
      @view.addProperty @event
      expect( @view.$el ).to.have '.property'

  describe '#removeProperty()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) -> '<input />'
      @event = $.Event 'click'
      @view.render()
      @view.$el.append '''
        <fieldset class="property not-persisted">
          <a class="remove-property">Remove property</a>
        </fieldset>
        '''

    afterEach ->
      Coreon.Helpers.input.restore()

    it 'is triggered by click on remove action', ->
      @view.removeProperty = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.property a.remove-property').trigger @event
      expect( @view.removeProperty ).to.have.been.calledOnce

    it 'removes property input set', ->
      @event.target = @view.$('.remove-property').get(0)
      @view.removeProperty @event
      expect( @view.$el ).to.not.have '.property'

  describe '#createTerm()', ->

    beforeEach ->
      @attrs = {}
      sinon.stub Coreon.Models, 'Term', =>
        @term = new Backbone.Model @attrs
        @term.save = sinon.spy => @request = $.Deferred()
        @term.errors = => @errors
        @term.persistedAttributes = => @persistedAttributes
        @term.properties = -> []
        @term.propertiesByKeyAndLang = -> {}
        @term
      @view.$el.append '''
        <form class="term create">
          <div class="submit">
            <button type="submit">Create term</button>
          </div>
        </form>
        '''
      @event = $.Event 'submit'
      @trigger = @view.$('form')
      @event.target = @trigger[0]
      terms = new Backbone.Collection
      terms.hasProperties = -> no
      @view.model.terms = -> terms

    afterEach ->
      Coreon.Models.Term.restore()

    it 'is triggered by submit', ->
      @view.createTerm = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('form').submit()
      expect( @view.createTerm ).to.have.been.calledOnce

    it 'prevents default', ->
      @event.preventDefault = sinon.spy()
      @view.createTerm @event
      expect( @event.preventDefault ).to.have.been.calledOnce

    it 'creates term', ->
      @view.model.id = '3456ghj'
      @view.createTerm @event
      expect( Coreon.Models.Term ).to.have.been.calledOnce
      expect( Coreon.Models.Term ).to.have.been.calledWithNew
      expect( Coreon.Models.Term ).to.have.been.calledWith
        concept_id: '3456ghj'
        properties: []
      expect( @term.save ).to.have.been.calledOnce
      expect( @term.save ).to.have.been.calledWith null, wait: yes

    it 'notifies about success', ->
      @attrs = value: 'Cowboyhut'
      I18n.t.withArgs('notifications.term.created', value: 'Cowboyhut')
        .returns 'Successfully created "Cowboyhut".'
      Coreon.Models.Notification.info = sinon.spy()
      @view.createTerm @event
      @request.resolve()
      expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
      expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'Successfully created "Cowboyhut".'

    it 'updates term from form', ->
      @view.$('form.term.create').prepend '''
        <input type="text" name="term[value]" value="high hat"/>
        <input type="text" name="term[lang]" value="en"/>
      '''
      @view.createTerm @event
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property 'value', 'high hat'
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property 'lang', 'en'

    it 'cleans up properties', ->
      @view.$('form.term.create').prepend '''
        <input type="text" name="term[properties][3][key]" value="status"/>
        '''
      @view.createTerm @event
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property('properties').with.lengthOf 1
      expect( Coreon.Models.Term.firstCall.args[0].properties[0] ).to.have.property 'key', 'status'

    it 'deletes previously set properties when empty', ->
      @view.createTerm @event
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property('properties').that.eql []

    context 'error', ->

      beforeEach ->
        @persistedAttributes = {}
        @errors = {}

      it 'rerenders form with errors', ->
        @view.createTerm @event
        @request.reject()
        expect( @view.$el ).to.have('form.term.create')
        expect( @view.$('form.term.create') ).to.have.lengthOf 1
        expect( @view.$('form.term.create') ).to.have '.error-summary'

      it 'renders properties within form', ->
        @view.createTerm @event
        @term.set 'properties', [ key: 'status' ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: 'status' ]
        @request.reject()
        expect( @view.$('form.term.create') ).to.have '.property'
        expect( @view.$('form.term.create .property') ).to.have.lengthOf 1

      it 'renders errors on properties', ->
        @view.createTerm @event
        @term.set 'properties', [ key: 'status' ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: 'status' ]
        @term.errors = -> { nested_errors_on_properties: [ value: ["can't be blank"] ] }
        @request.reject()
        expect( @view.$('form.term.create .property') ).to.have '.error-message'
        expect( @view.$('form.term.create .property .error-message') ).to.have.text "can't be blank"

      it 'increases index on add property link', ->
        @view.createTerm @event
        @term.set 'properties', [ key: 'status' ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: 'status' ]
        @request.reject()
        expect( @view.$('form.term.create .add-property') ).to.have.data 'index', 1

  describe '#updateTerm()', ->

    beforeEach ->
      @event = $.Event 'submit'
      @form = @view.$('form.term.update')
      @event.target = @form
      @view.model.terms = =>
        get: =>
          @term = new Backbone.Model
          @term.save = sinon.spy => @request = $.Deferred()
          @term

    it 'prevents default', ->
      @event.preventDefault = sinon.spy()
      @view.updateTerm @event
      expect( @event.preventDefault ).to.have.been.calledOnce

    it '#calls saveTerm()', ->
      @view.saveTerm = sinon.stub().returns false
      @view.updateTerm @event
      expect( @view.saveTerm ).to.have.been.calledOnce

  describe '#saveTerm()', ->

    it 'notifies about update', ->
      I18n.t.withArgs('notifications.term.saved').returns 'wohoow!'
      Coreon.Models.Notification.info = sinon.spy()
      model =
        save: => @request = $.Deferred()
        get: ->
      @view.saveTerm(model, {})
      @request.resolve()
      expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
      expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'wohoow!'

  describe '#cancel()', ->

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
      @event = $.Event 'click'
      @trigger = @view.$('form a.cancel')
      @event.target = @trigger[0]

    it 'is triggered by click on cancel link', ->
      @view.cancelForm = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.click()
      expect( @view.cancelForm ).to.have.been.calledOnce

    it 'is not triggered when link is disabled', ->
      @view.cancelForm = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.addClass 'disabled'
      @trigger.click()
      expect( @view.cancelForm ).to.not.have.been.called

    it 'prevents default action', ->
      @event.preventDefault = sinon.spy()
      @view.cancelForm @event
      expect( @event.preventDefault ).to.have.been.calledOnce

    it 'removes wrapping form', ->
      @view.$el.append '''
        <form class="other"></form>
      '''
      @view.cancelForm @event
      expect( @view.$el ).to.not.have 'form.term.create'
      expect( @view.$el ).to.have 'form.other'

    it 'shows related edit actions', ->
      $('#konacha').append @view.$el
      @view.cancelForm @event
      expect( @view.$('.edit a.add-term') ).to.be.visible

  describe '#reset()', ->

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
      @event = $.Event 'click'
      @trigger = @view.$('form a.reset')
      @event.target = @trigger[0]

    it 'is triggered by click on reset link', ->
      @view.reset = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.click()
      expect( @view.reset ).to.have.been.calledOnce

    it 'is not triggered when link is disabled', ->
      @view.reset = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.addClass 'disabled'
      @trigger.click()
      expect( @view.reset ).to.not.have.been.called

    it 'prevents default action', ->
      @event.preventDefault = sinon.spy()
      @view.reset @event
      expect( @event.preventDefault ).to.have.been.calledOnce

    it 'rerenders form', ->
      @view.render = sinon.spy()
      @view.reset @event
      expect( @view.render ).to.have.been.calledOnce

    it 'drops remote validation errors', ->
      @view.model.remoteError = "foo: ['must be bar']"
      @view.reset @event
      expect( @view.model ).to.have.property 'remoteError', null

    it 'restores previous state', ->
      @view.model.revert = sinon.stub().returns false
      @view.reset @event
      expect( @view.model.revert ).to.have.been.calledOnce

  describe '#removeTerm()', ->

    beforeEach ->
      $('#konacha')
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
      term = new Backbone.Model id: '518d2569edc797ef6d000008'
      term.properties = -> []
      term.propertiesByKeyAndLang = -> {}
      term.destroy = sinon.spy()
      terms = new Backbone.Collection [ term ]
      terms.hasProperties = -> no
      @view.model.terms = -> terms
      @event = $.Event 'click'
      @trigger = @view.$('a.remove-term')
      @event.target = @trigger[0]
      @view.confirm = sinon.spy()

    it 'is triggered by click on remove term link', ->
      @view.removeTerm = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.click()
      expect( @view.removeTerm ).to.have.been.calledOnce

    it 'renders confirmation dialog', ->
      I18n.t.withArgs('term.confirm_delete').returns 'This term will be deleted permanently.'
      @view.removeTerm @event
      expect( @view.confirm ).to.have.been.calledOnce
      options = @view.confirm.firstCall.args[0]
      expect( options ).to.have.property 'message', 'This term will be deleted permanently.'

    it 'marks term for deletetion', ->
      @view.removeTerm @event
      options = @view.confirm.firstCall.args[0]
      expect( options.container[0] ).to.equal @view.$('.term')[0]

    context 'destroy', ->

      beforeEach ->
        @view.removeTerm @event
        @action = @view.confirm.firstCall.args[0].action

      it 'removes term from listing', ->
        li = @view.$('.term')[0]
        @action()
        expect( $.contains(@view.$el[0], li) ).to.be.false

      it 'destroys model', ->
        term = @view.model.terms().at 0
        @action()
        expect( term.destroy ).to.have.been.calledOnce

      it 'notifies about destruction', ->
        I18n.t.withArgs('notifications.term.deleted').returns 'baaam!'
        Coreon.Models.Notification.info = sinon.spy()
        @action()
        expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
        expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'baaam!'

  describe '#delete()', ->

    beforeEach ->
      $('#konacha')
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
      @trigger = @view.$('a.delete-concept')
      @event = $.Event 'click'
      @event.target = @trigger[0]
      @view.confirm = sinon.spy()

    it 'is triggered by click on remove concept link', ->
      @view.delete = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.edit .delete-concept').trigger @event
      expect( @view.delete ).to.have.been.calledOnce

    it 'renders confirmation dialog', ->
      I18n.t.withArgs('concept.confirm_delete').returns 'This concept will be deleted permanently.'
      @view.delete @event
      expect( @view.confirm ).to.have.been.calledOnce
      options = @view.confirm.firstCall.args[0]
      expect( options ).to.have.property 'message', 'This concept will be deleted permanently.'

    it 'marks concept for deletetion', ->
      @view.delete @event
      options = @view.confirm.firstCall.args[0]
      expect( options.container[0] ).to.equal @view.$('.concept')[0]

    context 'confirm', ->

      fakeHits = (attrs) ->
        new Backbone.Collection attrs

      fakeConcept = -> {}

      beforeEach ->
        Coreon.application = repository: -> id: '8765jhgf'
        sinon.stub Backbone.history, 'navigate'
        @view.delete @event
        @action = @view.confirm.firstCall.args[0].action

      afterEach ->
        Coreon.application = null
        Backbone.history.navigate.restore()

      it 'redirects to repository root when done', ->
        Coreon.application = repository: -> id: '8765jhgf'
        @action()
        expect( Backbone.history.navigate ).to.have.been.calledOnce
        expect( Backbone.history.navigate ).to.have.been.calledWith '/8765jhgf', trigger: true

      it 'clears hits', ->
        hits = fakeHits [result: fakeConcept()]
        try
          sinon.stub Coreon.Collections.Hits, 'collection', -> hits
          @action()
          expect(hits).to.have.property 'length', 0
        finally
          Coreon.Collections.Hits.collection.restore()

      it 'destroys model', ->
        @view.model.destroy = sinon.spy()
        @action()
        expect( @view.model.destroy ).to.have.been.calledOnce

      it 'notifies about destruction', ->
        I18n.t.withArgs('notifications.concept.deleted').returns 'baaam!'
        Coreon.Models.Notification.info = sinon.spy()
        @action()
        expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
        expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'baaam!'

  describe 'clipboard interaction', ->

    beforeEach ->
      @collection = new Backbone.Collection
      sinon.stub Coreon.Collections.Clips, 'collection', => @collection
      sinon.spy @view, 'setClipboardButton'

    afterEach ->
      Coreon.Collections.Clips.collection.restore()
      @view.setClipboardButton.restore()

    it 'sets button if clips changing', ->
      @view.initialize()
      @collection.add @concept
      @collection.reset []
      expect( @view.setClipboardButton ).to.have.been.calledTwice
