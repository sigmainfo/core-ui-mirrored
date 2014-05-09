#= require spec_helper
#= require views/concepts/concept_view

describe 'Coreon.Views.Concepts.ConceptView', ->

  broaderAndNarrowerView = null
  property = null
  concept = null
  application = null
  template = null
  view = null

  buildConcept = (property, terms) ->
    concept = new Backbone.Model
    concept.info = -> {}
    concept.revert = ->
    concept.set 'properties', [ property ], silent: true
    concept.termsByLang = -> {}
    concept.terms = -> terms
    concept.propertiesByKeyAndLang = -> label: [ property ]
    properties = new Backbone.Collection
    concept.properties = -> properties
    concept.hasProperties = -> yes
    concept

  buildTerms = ->
    terms = new Backbone.Collection
    terms.hasProperties = -> no
    terms

  buildProperty = ->
    property = new Backbone.Model key: 'label', value: 'top hat'
    property.info = -> {}
    property

  buildApplication = ->
    application = new Backbone.Model
    settings = new Backbone.Model
    application.repositorySettings = -> settings
    application.langs = -> []
    application.sourceLang = -> 'none'
    application.targetLang = -> 'none'
    application

  beforeEach ->
    template = @stub(Coreon.Templates, 'concepts/concept').returns ''

    broaderAndNarrowerView = new Backbone.View
    @stub(Coreon.Views.Concepts.Shared, 'BroaderAndNarrowerView')
      .returns broaderAndNarrowerView

    propertiesView = new Backbone.View
    @stub(Coreon.Views.Properties, 'PropertiesView').returns propertiesView

    termsView = new Backbone.View
    @stub(Coreon.Views.Terms, 'TermsView').returns termsView

    property    = buildProperty()
    terms       = buildTerms()
    concept     = buildConcept property, terms
    application = buildApplication()

    view = new Coreon.Views.Concepts.ConceptView
      model: concept
      app: application

    @stub Coreon.Helpers, 'can'
    Coreon.Helpers.can.returns true

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect(view.$el).to.match '.concept'

  describe '#initialize()', ->

    beforeEach ->
      Coreon.application = buildApplication()

    afterEach ->
      delete Coreon.application

    it 'assigns app', ->
      app2 = buildApplication()
      view.initialize
        model: concept
        app: app2
      assigned = view.app
      expect(assigned).to.equal app2

    it 'defaults to global reference', ->
      app2 = Coreon.application
      view.initialize
        model: concept
        app: null
      assigned = view.app
      expect(assigned).to.equal app2

    it 'creates empty set for subviews', ->
      subviews = view.subviews
      expect(subviews).to.be.emptyArray

  describe '#render()', ->

    it 'can be chained', ->
      expect(view.render()).to.equal view

    context 'triggers', ->

      it 'is triggered by model change', ->
        view.render = @spy()
        view.initialize
          model: concept
          app: application
        concept.trigger 'change'
        expect(view.render).to.have.been.calledOnce

      it 'is triggered by edit mode change', ->
        view.render = @spy()
        view.initialize
          model: concept
          app: application
        application.trigger 'change:editing'
        expect(view.render).to.have.been.calledOnce
        expect(view.render).to.have.been.calledOn view

    context 'edit mode', ->

      it 'is in show concept mode by default', ->
        application.set 'editing', off, silent: yes
        view.render()
        expect(view.$el).to.have.class 'show'
        expect(view.$el).to.not.have.class 'edit'

      it 'marks el to be in edit mode', ->
        application.set 'editing', on, silent: yes
        view.render()
        expect(view.$el).to.have.class 'edit'
        expect(view.$el).to.not.have.class 'show'

    context 'subviews', ->

      it 'removes deprecated subviews', ->
        remove = @spy()
        old = remove: remove
        view.subviews = [old]
        view.render()
        expect(remove).to.have.been.calledOnce

      it 'clears references to subviews', ->
        old = remove: ->
        view.subviews = [old]
        view.render()
        subviews = view.subviews
        expect(subviews).to.not.include old

      it 'renders subview', ->
        template.returns '<div class="concept-head"><div>'
        broaderAndNarrowerView.render = @stub().returns broaderAndNarrowerView
        view.render()
        expect(broaderAndNarrowerView.render).to.have.been.calledOnce
        expect($.contains view.el, broaderAndNarrowerView.el).to.be.true

    context 'template', ->

      it 'clears deprecated markup', ->
        view.$el.html '<div class="old-stuff">Deprecated</div>'
        view.render()
        old = view.$ 'div.old-stuff'
        expect(old).to.not.exist

      it 'inserts newly rendered template', ->
        template.returns '<div class="new-stuff">Tempus fugit</div>'
        view.render()
        el = view.$el
        expect(el).to.have '.new-stuff'

      context 'passing in data', ->

        firstArg = (spy) -> spy.firstCall.args[0]

        it 'references model', ->
          view.render()
          data = firstArg template
          expect(data).to.have.property 'model', concept

        it 'extracts relevant data from concept', ->
          conceptData =
            id: 'c1234'
            label: 'My Concept'
            info: created_at: 'yesterday'
          view.conceptData = -> conceptData
          view.render()
          data = firstArg template
          expect(data).to.have.property 'concept', conceptData

        it 'passes terms as lang groups to template', ->
          termGroups = [[ 'de', [] ]]
          view.termGroups = -> termGroups
          view.render()
          data = firstArg template
          expect(data).to.have.property 'langs', termGroups

        it 'checks for term properties', ->
          terms = concept.terms()
          terms.hasProperties = -> yes
          view.render()
          data = firstArg template
          expect(data).to.have.property 'hasTermProperties', yes

        it 'passes edit states', ->
          application.set 'editing', on, silent: yes
          view.editProperties = on
          view.editTerm = on
          view.render()
          data = firstArg template
          expect(data).to.have.property 'editing', on
          expect(data).to.have.property 'editProperties', on
          expect(data).to.have.property 'editTerm', on

    context 'properties', ->

      subview = null
      constructor = null
      properties = null

      beforeEach ->
        subview = new Backbone.View
        constructor = Coreon.Views.Properties.PropertiesView
        constructor.returns subview
        properties = new Backbone.Collection
        concept.hasProperties = -> yes
        concept.publicProperties = -> properties
        template.returns '''
          <div class="broader-and-narrower"></div>
        '''

      it 'creates subview', ->
        constructor.withArgs(model: properties).returns subview
        view.render()
        expect(constructor).to.have.been.calledOnce
        subviews = view.subviews
        expect(subviews).to.include subview

      it 'creates subview only when there are any properties', ->
        concept.hasProperties = -> no
        view.render()
        expect(constructor).to.not.have.been.called

      it 'renders subview', ->
        render = @stub subview, 'render'
        render.returns subview
        view.render()
        expect(render).to.have.been.calledOnce
        el = view.el
        node = subview.el
        expect($.contains el, node).to.be.true


      #TODO 140508 [tc] extract edit properties view

    context 'terms', ->

      subview = null
      constructor = null
      terms = null

      beforeEach ->
        constructor = Coreon.Views.Terms.TermsView
        constructor.returns subview
        terms = buildTerms()
        concept.terms = -> terms

      it 'creates subview instance', ->
        subview = new Backbone.View
        constructor.withArgs(model: terms).returns subview
        view.render()
        expect(constructor).to.have.been.calledOnce
        subviews = view.subviews
        expect(subviews).to.include subview

      it 'renders subview', ->
        render = @stub subview, 'render'
        render.returns subview
        view.render()
        expect(render).to.have.been.calledOnce
        el = view.el
        node = subview.el
        expect($.contains el, node).to.be.true

      context 'editing', ->

        term = null

        beforeEach ->
          #TODO 140507 [tc] extract edit template view
          template.restore()
          view.template = Coreon.Templates['concepts/concept']

          application.set 'editing', on, silent: yes
          @stub Coreon.Templates, 'shared/info'
          concept.set 'terms', [ lang: 'de', value: 'top head' ], silent: true
          term = new Backbone.Model value: 'top head'
          term.info = -> {}
          term.properties = -> new Backbone.Collection
          term.propertiesByKey = -> []
          concept.termsByLang = => de: [ term ]
          application.langs = -> [ 'de' ]

        it 'renders container', ->
          view.render()
          expect( view.$el ).to.have '.terms'

        it 'renders section for languages', ->
          term1 = new Backbone.Model
          term1.info = -> {}
          term1.propertiesByKey = -> []
          term2 = new Backbone.Model
          term2.info = -> {}
          term2.propertiesByKey = -> []
          application.langs = -> [ 'de', 'en', 'hu' ]
          concept.termsByLang = ->
            de: [ term1 ]
            en: [ term2 ]
          view.render()
          expect( view.$el ).to.have '.terms section.language'
          expect( view.$('section.language') ).to.have.lengthOf 2
          expect( view.$('section.language').eq(0) ).to.have.class 'de'
          expect( view.$('section.language').eq(1) ).to.have.class 'en'

        it 'renders caption for language', ->
          concept.termsByLang = => de: [ term ]
          view.render()
          expect( view.$('.language') ).to.have 'h3'
          expect( view.$('.language h3') ).to.have.text 'de'

        it 'renders terms', ->
          term.set 'value', 'top hat', silent: true
          concept.termsByLang = => de: [ term ]
          view.render()
          expect( view.$('.language') ).to.have '.term'
          expect( view.$('.term') ).to.have '.value'
          expect( view.$('.term .value') ).to.have.text 'top hat'

        it 'renders placeholder text when terms in source lang are empty', ->
          I18n.t.withArgs('terms.empty').returns 'No terms for this language'
          application.sourceLang = -> 'de'
          application.langs = -> ['de', 'hu', 'en']
          concept.termsByLang = => {}
          view.render()
          expect( view.$('.language.de') ).to.not.have '.term'
          expect( view.$('.language.de') ).to.have '.no-terms'
          expect( view.$('.de .no-terms') ).to.have.text 'No terms for this language'

        it 'renders placeholder text when terms in target lang are empty', ->
          I18n.t.withArgs('terms.empty').returns 'No terms for this language'
          application.targetLang = -> 'hu'
          application.langs = -> ['de', 'hu', 'en']
          concept.termsByLang = => {}
          view.render()
          expect( view.$('.language.hu') ).to.not.have '.term'
          expect( view.$('.language.hu') ).to.have '.no-terms'
          expect( view.$('.hu .no-terms') ).to.have.text 'No terms for this language'

        it 'renders unknown langs', ->
          term.set 'value', 'foo', silent: true
          application.langs = -> ['de', 'hu', 'en']
          concept.termsByLang = => ko: [ term ]
          view.render()
          expect( view.$('.language.ko') ).to.exist
          expect( view.$('.language.ko') ).to.have '.term'
          expect( view.$('.ko .term .value') ).to.have.text 'foo'

        it 'renders system info for of term', ->
          term.info = -> id: '#1234'
          Coreon.Templates['shared/info'].withArgs(data: id: '#1234')
            .returns '<div class="system-info">id: #1234</div>'
          view.render()
          expect( view.$('.term') ).to.have '.system-info'

        context 'term properties', ->

          properties = null

          beforeEach ->
            property = new Backbone.Model key: 'source', value: 'Wikipedia'
            property.info = -> {}
            properties = [ key: 'source', properties: [ property ] ]
            term.propertiesByKey = -> properties
            terms = new Backbone.Collection [term]
            terms.hasProperties = -> no
            concept.terms = -> terms

          it 'renders term properties', ->
            view.render()
            expect( view.$('.term') ).to.have '.properties'

          it 'collapses properties by default', ->
            view.render()
            expect( view.$('.term .properties') ).to.have.class 'collapsed'
            expect( view.$('.term .properties > *:nth-child(2)') ).to.have.css 'display', 'none'

          it 'renders toggle for properties', ->
            I18n.t.withArgs('terms.properties.toggle.hint').returns 'Toggle properties'
            view.render()
            expect( view.$('.term .properties h3') ).to.have.attr 'title', 'Toggle properties'

          it 'renders toggle all button', ->
            I18n.t.withArgs('terms.properties.toggle-all.hint').returns 'Toggle all properties'
            terms.hasProperties = -> yes
            view.render()
            expect( view.$('.terms') ).to.have '> .properties-toggle'
            toggle = view.$('.terms > .properties-toggle')
            expect( toggle ).to.have.attr 'title', 'Toggle all properties'

          it 'renders toggle button only when applicable', ->
            term.propertiesByKeyAndLang = -> {}
            terms.hasProperties = -> no
            view.render()
            expect( view.$('.terms') ).to.not.have '.properties-toggle'

        context 'with edit privileges', ->

          beforeEach ->
            Coreon.Helpers.can.returns true

          it 'renders add term link', ->
            I18n.t.withArgs('term.new').returns 'Add term'
            view.render()
            expect( view.$('.terms') ).to.have '.edit a.add-term'
            expect( view.$('.add-term') ).to.have.text 'Add term'

          it 'renders remove term links', ->
            I18n.t.withArgs('term.delete').returns 'Remove term'
            term.id = '56789fghj'
            view.render()
            expect( view.$('.term') ).to.have '.edit a.remove-term'
            expect( view.$('.term a.remove-term') ).to.have.text 'Remove term'
            expect( view.$('.term a.remove-term') ).to.have.data 'id', '56789fghj'

          it 'renders edit term links', ->
            I18n.t.withArgs('term.edit.label').returns 'Edit term'
            term.id = '56789fghj'
            view.render()
            expect( view.$('.term') ).to.have '.edit a.edit-term'
            expect( view.$('.term a.edit-term') ).to.have.text 'Edit term'
            expect( view.$('.term a.edit-term') ).to.have.data 'id', '56789fghj'

        context 'without edit privileges', ->

          beforeEach ->
            Coreon.Helpers.can.returns false

          it 'does not render add term link', ->
            view.render()
            expect( view.$el ).to.not.have '.add-term'

          it 'does not render remove term link', ->
            view.model.set 'terms', [ lang: 'de', value: 'top head' ], silent: true
            view.render()
            expect( view.$('.term') ).to.not.have 'a.remove-term'

  describe '#conceptData()', ->

    it 'extracts id and label from model', ->
      concept.set
        id: 'c123'
        label: 'My Concept'
      , silent: yes
      data = view.conceptData()
      expect(data).to.have.property 'id', 'c123'
      expect(data).to.have.property 'label', 'My Concept'

    it 'assigns info', ->
      info = { created_at: '2014-05-05' }
      concept.info = -> info
      data = view.conceptData()
      expect(data).to.have.property 'info', info

  describe '#termGroups()', ->

    buildTerm = (attrs = {}) ->
      _(attrs).defaults lang: 'en', value: 'foo'
      new Backbone.Model attrs

    beforeEach ->
      application.langs = -> ['en', 'de', 'el']

    it 'groups terms by lang', ->
      terms1 = [ buildTerm lang: 'el' ]
      terms2 = [ buildTerm lang: 'de' ]
      concept.termsByLang = ->
        el: terms1
        de: terms2
      termGroups = view.termGroups()
      expect(termGroups).to.eql [['de', terms2], ['el', terms1]]

    it 'creates empty group for source lang', ->
      concept.termsByLang = -> {}
      application.sourceLang = -> 'el'
      termGroups = view.termGroups()
      expect(termGroups).to.eql [['el', [] ]]

    it 'creates empty group for target lang', ->
      concept.termsByLang = -> {}
      application.targetLang = -> 'el'
      termGroups = view.termGroups()
      expect(termGroups).to.eql [['el', [] ]]

    it 'appends concept specific lang', ->
      terms1 = [ buildTerm lang: 'hu' ]
      terms2 = [ buildTerm lang: 'el' ]
      concept.termsByLang = ->
        hu: terms1
        el: terms2
      termGroups = view.termGroups()
      expect(termGroups).to.eql [['el', terms2], ['hu', terms1]]

  describe '#toggleSystemInfo()', ->

    beforeEach ->
      view.$el.append """
        <section>
          <div class="actions">
            <h3 class="toggle-system-info">INFO</h3>
          </div>
          <div class="system-info">foo</div>
        </section>
      """
      $("#konacha").append view.$el

    it "is triggered by click on system info toggle", ->
      view.toggleSystemInfo = @spy()
      view.delegateEvents()
      view.$(".toggle-system-info").click()
      expect( view.toggleSystemInfo ).to.have.been.calledOnce

    it "toggles system info", ->
      view.toggleSystemInfo()
      expect( view.$(".system-info") ).to.be.hidden
      view.toggleSystemInfo()
      expect( view.$(".system-info") ).to.be.visible

  describe "toggleSection()", ->

    event = null

    beforeEach ->
      view.$el.append """
        <section>
          <h3>PROPERTIES</h3>
          <div>foo</div>
        </section>
        """
      event = $.Event()

    it 'is triggered by click on caption for section', ->
      view.toggleSection = @stub().returns false
      view.delegateEvents()
      view.$('section *:first-child').first().click()
      expect( view.toggleSection ).to.have.been.calledOnce

    it 'is not triggered for section within a form', ->
      view.toggleSection = @stub().returns false
      view.delegateEvents()
      view.$('section').wrap '<form>'
      view.$('section *:first-child').first().click()
      expect( view.toggleSection ).to.not.have.been.called

    it 'toggles visibility of section content', ->
      $('#konacha').append view.$el
      event.target = view.$('h3').get(0)
      view.toggleSection event
      expect( view.$('section div') ).to.be.hidden
      view.toggleSection event
      expect( view.$('section div') ).to.be.visible

    it 'toggles state of section', ->
      event.target = view.$('h3').get(0)
      view.toggleSection event
      expect( view.$('section') ).to.have.class 'collapsed'
      view.toggleSection event
      expect( view.$('section') ).to.not.have.class 'collapsed'

  describe '#selectProperty()', ->

    event = null
    tab = null

    beforeEach ->
      view.$el.append '''
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
      tab = view.$('.index li').eq(1)

      event = $.Event 'click'
      event.target = tab[0]

    it 'is triggered by click on selector', ->
      view.selectProperty = @stub().returns false
      view.delegateEvents()
      tab.trigger event
      expect( view.selectProperty ).to.have.been.calledOnce
      expect( view.selectProperty ).to.have.been.calledWith event

    it 'updates selection', ->
      view.selectProperty event
      expect( view.$('.index li').eq(1) ).to.have.class 'selected'
      expect( view.$('.index li').eq(0) ).to.not.have.class 'selected'
      expect( view.$('.values li').eq(1) ).to.have.class 'selected'
      expect( view.$('.values li').eq(0) ).to.not.have.class 'selected'

  describe '#toggleEditMode()', ->

    toggle = null
    event = null

    beforeEach ->
      view.$el.html '<a class="toggle-edit-mode">Edit mode</a>'
      toggle = view.$('.toggle-edit-mode')
      event = $.Event 'click'
      event.target = toggle[0]

    it 'is triggered by click on edit mode toggle', ->
      toggleEditMode = @stub view, 'toggleEditMode'
      view.delegateEvents()
      toggle.trigger event
      expect(toggleEditMode).to.have.been.calledOnce

    it 'toggles edit mode from off to on', ->
      application.set 'editing', off, silent: yes
      view.toggleEditMode event
      expect(application.get 'editing').to.be.true

    it 'toggles edit mode from on to off', ->
      application.set 'editing', on, silent: yes
      view.toggleEditMode event
      expect(application.get 'editing').to.be.false

  describe '#toggleEditConceptProperties()', ->

    beforeEach ->
      concept.properties = -> models: []
      concept.persistedAttributes = -> {}
      application.set 'editing', on, silent: yes
      view.editProperties = no
      view.$el.html '''
        <section class="properties">
          <div class="edit">
            <a class="edit-properties" href="javascript:void(0)">
              Edit properties
            </a>
          </div>
        </section>
      '''

    it 'is triggered by click on edit-properties toggle', ->
      view.toggleEditConceptProperties = @stub().returns false
      view.delegateEvents()
      view.$('.edit-properties').click()
      expect( view.toggleEditConceptProperties ).to.have.been.calledOnce

    it 'toggles edit properties value', ->
      expect( view.editProperties ).to.be.false
      view.$('.edit-properties').click()
      expect( view.editProperties ).to.be.true

    it 'rerenders the view', ->
      view.render = @spy()
      view.delegateEvents()
      view.$('.edit-properties').click()
      expect( view.render ).to.have.been.calledOnce

  describe '#addTerm()', ->

    beforeEach ->
      application.set 'editing', on, silent: yes
      view.$el.html '''
        <div class="edit">
          <a class="add-term" href="">Add term</a>
        </div>
      '''

    it 'is triggered by click on add-term link', ->
      view.addTerm = @stub().returns false
      view.delegateEvents()
      view.$('.add-term').click()
      expect( view.addTerm ).to.have.been.calledOnce

  describe '#addProperty()', ->

    event = null
    trigger = null

    beforeEach ->
      view.$el.append '''
        <section class="properties">
          <h3>PROPERTIES</h3>
          <div class="edit">
            <a class="add-property">Add property</a>
          </div>
        </section>
        '''
      event = $.Event 'click'
      trigger = view.$('.add-property')
      event.target = trigger[0]

    it 'is triggered by click on add property link', ->
      view.addProperty = @stub().returns false
      view.delegateEvents()
      view.$('.add-property').click()
      expect( view.addProperty ).to.have.been.calledOnce

    it 'inserts property inputs', ->
      view.addProperty event
      expect( view.$el ).to.have '.property'

  describe '#removeProperty()', ->

    event = null

    beforeEach ->
      @stub Coreon.Helpers, 'input', (name, attr, model, options) -> '<input />'
      event = $.Event 'click'
      view.render()
      view.$el.append '''
        <fieldset class="property not-persisted">
          <a class="remove-property">Remove property</a>
        </fieldset>
        '''

    it 'is triggered by click on remove action', ->
      view.removeProperty = @stub().returns false
      view.delegateEvents()
      view.$('.property a.remove-property').trigger event
      expect( view.removeProperty ).to.have.been.calledOnce

    it 'removes property input set', ->
      event.target = view.$('.remove-property').get(0)
      view.removeProperty event
      expect( view.$el ).to.not.have '.property'

  describe '#createTerm()', ->

    term = null
    event = null
    attrs = null
    request = null
    errors = null
    persistedAttributes = null

    beforeEach ->
      attrs = {}
      @stub Coreon.Models, 'Term', =>
        term = new Backbone.Model attrs
        term.save = @spy -> request = $.Deferred()
        term.errors = -> errors
        term.persistedAttributes = -> persistedAttributes
        term.properties = -> []
        term.propertiesByKeyAndLang = -> {}
        term
      view.$el.append '''
        <form class="term create">
          <div class="submit">
            <button type="submit">Create term</button>
          </div>
        </form>
        '''
      event = $.Event 'submit'
      trigger = view.$('form')
      event.target = trigger[0]
      terms = new Backbone.Collection
      terms.hasProperties = -> no
      view.model.terms = -> terms

    it 'is triggered by submit', ->
      view.createTerm = @stub().returns false
      view.delegateEvents()
      view.$('form').submit()
      expect( view.createTerm ).to.have.been.calledOnce

    it 'prevents default', ->
      event.preventDefault = @spy()
      view.createTerm event
      expect( event.preventDefault ).to.have.been.calledOnce

    it 'creates term', ->
      view.model.id = '3456ghj'
      view.createTerm event
      expect( Coreon.Models.Term ).to.have.been.calledOnce
      expect( Coreon.Models.Term ).to.have.been.calledWithNew
      expect( Coreon.Models.Term ).to.have.been.calledWith
        concept_id: '3456ghj'
        properties: []
      expect( term.save ).to.have.been.calledOnce
      expect( term.save ).to.have.been.calledWith null, wait: yes

    it 'notifies about success', ->
      attrs = value: 'Cowboyhut'
      I18n.t.withArgs('notifications.term.created', value: 'Cowboyhut')
        .returns 'Successfully created "Cowboyhut".'
      Coreon.Models.Notification.info = @spy()
      view.createTerm event
      request.resolve()
      expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
      expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'Successfully created "Cowboyhut".'

    it 'updates term from form', ->
      view.$('form.term.create').prepend '''
        <input type="text" name="term[value]" value="high hat"/>
        <input type="text" name="term[lang]" value="en"/>
      '''
      view.createTerm event
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property 'value', 'high hat'
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property 'lang', 'en'

    it 'cleans up properties', ->
      view.$('form.term.create').prepend '''
        <input type="text" name="term[properties][3][key]" value="status"/>
        '''
      view.createTerm event
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property('properties').with.lengthOf 1
      expect( Coreon.Models.Term.firstCall.args[0].properties[0] ).to.have.property 'key', 'status'

    it 'deletes previously set properties when empty', ->
      view.createTerm event
      expect( Coreon.Models.Term.firstCall.args[0] ).to.have.property('properties').that.eql []

    context 'error', ->

      beforeEach ->
        persistedAttributes = {}
        errors = {}

      it 'rerenders form with errors', ->
        view.createTerm event
        request.reject()
        expect( view.$el ).to.have('form.term.create')
        expect( view.$('form.term.create') ).to.have.lengthOf 1
        expect( view.$('form.term.create') ).to.have '.error-summary'

      it 'renders properties within form', ->
        view.createTerm event
        term.set 'properties', [ key: 'status' ], silent: true
        term.properties = -> models: [ new Backbone.Model key: 'status' ]
        request.reject()
        expect( view.$('form.term.create') ).to.have '.property'
        expect( view.$('form.term.create .property') ).to.have.lengthOf 1

      it 'renders errors on properties', ->
        view.createTerm event
        term.set 'properties', [ key: 'status' ], silent: true
        term.properties = -> models: [ new Backbone.Model key: 'status' ]
        term.errors = -> { nested_errors_on_properties: [ value: ["can't be blank"] ] }
        request.reject()
        expect( view.$('form.term.create .property') ).to.have '.error-message'
        expect( view.$('form.term.create .property .error-message') ).to.have.text "can't be blank"

      it 'increases index on add property link', ->
        view.createTerm event
        term.set 'properties', [ key: 'status' ], silent: true
        term.properties = -> models: [ new Backbone.Model key: 'status' ]
        request.reject()
        expect( view.$('form.term.create .add-property') ).to.have.data 'index', 1

  describe '#updateTerm()', ->

    event = null
    form = null

    beforeEach ->
      event = $.Event 'submit'
      form = view.$('form.term.update')
      event.target = form
      view.model.terms = =>
        get: =>
          term = new Backbone.Model
          term.save = @spy => request = $.Deferred()
          term

    it 'prevents default', ->
      event.preventDefault = @spy()
      view.updateTerm event
      expect( event.preventDefault ).to.have.been.calledOnce

    it '#calls saveTerm()', ->
      view.saveTerm = @stub().returns false
      view.updateTerm event
      expect( view.saveTerm ).to.have.been.calledOnce

  describe '#saveTerm()', ->

    request = null

    it 'notifies about update', ->
      I18n.t.withArgs('notifications.term.saved').returns 'wohoow!'
      Coreon.Models.Notification.info = @spy()
      model =
        save: -> request = $.Deferred()
        get: ->
      view.saveTerm(model, {})
      request.resolve()
      expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
      expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'wohoow!'

  describe '#cancel()', ->

    event = null
    trigger = null

    beforeEach ->
      view.$el.append '''
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
      event = $.Event 'click'
      trigger = view.$('form a.cancel')
      event.target = trigger[0]

    it 'is triggered by click on cancel link', ->
      view.cancelForm = @stub().returns false
      view.delegateEvents()
      trigger.click()
      expect( view.cancelForm ).to.have.been.calledOnce

    it 'is not triggered when link is disabled', ->
      view.cancelForm = @stub().returns false
      view.delegateEvents()
      trigger.addClass 'disabled'
      trigger.click()
      expect( view.cancelForm ).to.not.have.been.called

    it 'prevents default action', ->
      event.preventDefault = @spy()
      view.cancelForm event
      expect( event.preventDefault ).to.have.been.calledOnce

    it 'removes wrapping form', ->
      view.$el.append '''
        <form class="other"></form>
      '''
      view.cancelForm event
      expect( view.$el ).to.not.have 'form.term.create'
      expect( view.$el ).to.have 'form.other'

    it 'shows related edit actions', ->
      $('#konacha').append view.$el
      view.cancelForm event
      expect( view.$('.edit a.add-term') ).to.be.visible

  describe '#reset()', ->

    event = null
    trigger = null

    beforeEach ->
      view.$el.append '''
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
      event = $.Event 'click'
      trigger = view.$('form a.reset')
      event.target = trigger[0]

    it 'is triggered by click on reset link', ->
      view.reset = @stub().returns false
      view.delegateEvents()
      trigger.click()
      expect( view.reset ).to.have.been.calledOnce

    it 'is not triggered when link is disabled', ->
      view.reset = @stub().returns false
      view.delegateEvents()
      trigger.addClass 'disabled'
      trigger.click()
      expect( view.reset ).to.not.have.been.called

    it 'prevents default action', ->
      event.preventDefault = @spy()
      view.reset event
      expect( event.preventDefault ).to.have.been.calledOnce

    it 'rerenders form', ->
      view.render = @spy()
      view.reset event
      expect( view.render ).to.have.been.calledOnce

    it 'drops remote validation errors', ->
      view.model.remoteError = "foo: ['must be bar']"
      view.reset event
      expect( view.model ).to.have.property 'remoteError', null

    it 'restores previous state', ->
      view.model.revert = @stub().returns false
      view.reset event
      expect( view.model.revert ).to.have.been.calledOnce

  describe '#removeTerm()', ->

    event = null
    trigger = null

    beforeEach ->
      $('#konacha')
        .append(view.$el)
        .append '''
        <div id="coreon-modal"></div>
        '''
      view.$el.append '''
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
      term.destroy = @spy()
      terms = new Backbone.Collection [ term ]
      terms.hasProperties = -> no
      view.model.terms = -> terms
      event = $.Event 'click'
      trigger = view.$('a.remove-term')
      event.target = trigger[0]
      view.confirm = @spy()

    it 'is triggered by click on remove term link', ->
      view.removeTerm = @stub().returns false
      view.delegateEvents()
      trigger.click()
      expect( view.removeTerm ).to.have.been.calledOnce

    it 'renders confirmation dialog', ->
      I18n.t.withArgs('term.confirm_delete').returns 'This term will be deleted permanently.'
      view.removeTerm event
      expect( view.confirm ).to.have.been.calledOnce
      options = view.confirm.firstCall.args[0]
      expect( options ).to.have.property 'message', 'This term will be deleted permanently.'

    it 'marks term for deletetion', ->
      view.removeTerm event
      options = view.confirm.firstCall.args[0]
      expect( options.container[0] ).to.equal view.$('.term')[0]

    context 'destroy', ->

      action = null

      beforeEach ->
        view.removeTerm event
        action = view.confirm.firstCall.args[0].action

      it 'removes term from listing', ->
        li = view.$('.term')[0]
        action()
        expect( $.contains(view.$el[0], li) ).to.be.false

      it 'destroys model', ->
        term = view.model.terms().at 0
        action()
        expect( term.destroy ).to.have.been.calledOnce

      it 'notifies about destruction', ->
        I18n.t.withArgs('notifications.term.deleted').returns 'baaam!'
        Coreon.Models.Notification.info = @spy()
        action()
        expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
        expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'baaam!'

  describe '#delete()', ->

    event = null

    beforeEach ->
      $('#konacha')
        .append(view.$el)
        .append '''
        <div id="coreon-modal"></div>
        '''
      view.$el.append '''
        <div class="concept">
          <div class="edit">
            <a class="delete-concept" href="javascript:void(0)">Delete concept</a>
          </div>
        </div>
        '''
      trigger = view.$('a.delete-concept')
      event = $.Event 'click'
      event.target = trigger[0]
      view.confirm = @spy()

    it 'is triggered by click on remove concept link', ->
      view.delete = @stub().returns false
      view.delegateEvents()
      view.$('.edit .delete-concept').trigger event
      expect( view.delete ).to.have.been.calledOnce

    it 'renders confirmation dialog', ->
      I18n.t.withArgs('concept.confirm_delete').returns 'This concept will be deleted permanently.'
      view.delete event
      expect( view.confirm ).to.have.been.calledOnce
      options = view.confirm.firstCall.args[0]
      expect( options ).to.have.property 'message', 'This concept will be deleted permanently.'

    it 'marks concept for deletetion', ->
      view.delete event
      options = view.confirm.firstCall.args[0]
      expect( options.container[0] ).to.equal view.$('.concept')[0]

    context 'confirm', ->

      fakeHits = (attrs) ->
        new Backbone.Collection attrs

      fakeConcept = -> {}

      action = null

      beforeEach ->
        application.repository = -> id: '8765jhgf'
        @stub Backbone.history, 'navigate'
        view.delete event
        action = view.confirm.firstCall.args[0].action

      it 'redirects to repository root when done', ->
        application.repository = -> id: '8765jhgf'
        action()
        expect( Backbone.history.navigate ).to.have.been.calledOnce
        expect( Backbone.history.navigate ).to.have.been.calledWith '/8765jhgf', trigger: true

      it 'clears hits', ->
        hits = fakeHits [result: fakeConcept()]
        @stub Coreon.Collections.Hits, 'collection', -> hits
        action()
        expect(hits).to.have.property 'length', 0

      it 'destroys model', ->
        view.model.destroy = @spy()
        action()
        expect( view.model.destroy ).to.have.been.calledOnce

      it 'notifies about destruction', ->
        I18n.t.withArgs('notifications.concept.deleted').returns 'baaam!'
        Coreon.Models.Notification.info = @spy()
        action()
        expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
        expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'baaam!'

  describe 'clipboard interaction', ->

    collection = null

    beforeEach ->
      collection = new Backbone.Collection
      @stub Coreon.Collections.Clips, 'collection', => collection
      @spy view, 'setClipboardButton'

    it 'sets button if clips changing', ->
      view.initialize
        model: concept
        app: application
      collection.add concept
      collection.reset []
      expect(view.setClipboardButton).to.have.been.calledTwice
