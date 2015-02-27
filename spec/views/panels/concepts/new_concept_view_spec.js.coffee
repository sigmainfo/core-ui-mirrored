#= require spec_helper
#= require views/panels/concepts/new_concept_view

describe 'Coreon.Views.Panels.Concepts.NewConceptView', ->

  beforeEach ->
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.languageOptions = -> []
    Coreon.Models.RepositorySettings.propertiesFor = (model) -> []
    Coreon.Models.RepositorySettings.optionalPropertiesFor = (model) -> []
    sinon.stub I18n, 't'
    sinon.stub Coreon.Views.Concepts.Shared, 'BroaderAndNarrowerView', (options) =>
      @broaderAndNarrower = new Backbone.View options
    @editProperties = null
    sinon.stub Coreon.Views.Properties, 'EditPropertiesView', (options) =>
      @editProperties = new Backbone.View options
      @editProperties.updateValid = sinon.spy()
      @editProperties.render = sinon.spy()
      @editProperties.serializeArray = sinon.spy()
      @editProperties.serializeAssetsArray = sinon.spy()
      @editProperties
    @model = new Backbone.Model
        properties: []
        terms: []
        superconcept_ids: []
    @propertiesWithDefaults = []
    @model.propertiesWithDefaults = -> @propertiesWithDefaults
    @view = new Coreon.Views.Panels.Concepts.NewConceptView
      model: @model
    @view.saveAssets = ->
    @view.model.properties = -> new Backbone.Collection
    @view.model.terms = -> new Backbone.Collection
    @view.model.errors = -> null

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()
    Coreon.Views.Properties.EditPropertiesView.restore()

  it 'is a Backbone view', ->
    @view.should.be.an.instanceof Backbone.View

  it 'is classified as new concept', ->
    @view.$el.should.have.class 'concept'
    @view.$el.should.have.class 'new'

  describe '#initialize()', ->

    it 'assigns app', ->
      app = new Backbone.Model
      @view.initialize {}, app: app
      assigned = @view.app
      expect(assigned).to.equal app

    it 'creates view for broader & narrower section', ->
      should.exist @view.broaderAndNarrower
      @view.broaderAndNarrower.should.equal @broaderAndNarrower
      @view.broaderAndNarrower.should.have.property 'model', @view.model

  describe '#render()', ->

    it 'can be chained', ->
      @view.render().should.equal @view

    it 'renders caption', ->
      @view.model.set 'label', '<New concept>', silent: true
      @view.render()
      @view.$el.should.have 'h2.label'
      @view.$('h2.label').should.have.text '<New concept>'

    context 'broader and narrower', ->

      it 'renders view', ->
        @view.broaderAndNarrower.render = sinon.spy()
        @view.render()
        @view.broaderAndNarrower.render.should.have.been.calledOnce

      it 'renders view only once', ->
        @view.broaderAndNarrower.render = sinon.spy()
        @view.render()
        @view.render()
        @view.broaderAndNarrower.render.should.have.been.calledOnce

      it 'appends el', ->
        @view.render()
        $.contains(@view.el, @view.broaderAndNarrower.el).should.be.true

    context 'form', ->

      it 'renders submit button', ->
        I18n.t.withArgs('concept.create').returns 'Create concept'
        @view.render()
        @view.$el.should.have 'form'
        @view.$el.should.have 'form button[type="submit"]'
        @view.$('form button[type="submit"]').should.have.text 'Create concept'

      it 'renders a cancel button', ->
        I18n.t.withArgs('form.cancel').returns 'Cancel'
        @view.render()
        @view.$el.should.have 'a.cancel'
        @view.$('a.cancel').should.have.text 'Cancel'

    context 'properties', ->

      it 'renders view for concept properties editing', ->
        @view.render()
        should.exist @view.editProperties
        @view.editProperties.should.equal @editProperties
        @view.editProperties.should.have.property 'collection', @view.model.propertiesWithDefaults()

      it 'renders property edit view', ->
        @view.render()
        expect(@editProperties.render).to.have.been.calledOnce

    context 'terms', ->

      beforeEach ->
        @term = new Backbone.Model
        @term.properties = -> models: []
        @term.errors = -> null
        @term.propertiesWithDefaults = -> []
        @view.model.terms = => models: []
        @view.listenTo = sinon.spy()
        termView = sinon.stub Coreon.Views.Panels.Terms, 'NewTermView', ->
          render: -> { $el: $ '' }
          updateValid: ->
          editProperties: new Coreon.Views.Properties.EditPropertiesView

      it 'renders term views', ->
        @term.set lang: 'de', silent: true
        @view.model.terms = => models: [ @term ]
        @view.render()
        expect(Coreon.Views.Panels.Terms.NewTermView).to.have.been.calledWithNew

  describe '#addTerm()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) ->
        "<input id='#{name}-#{options.index}-#{attr}' name='#{options.scope}[#{attr}]' #{'required' if options.required}/>"
      @view.render()
      @event = $.Event 'click'
      @event.target = @view.$('a.add-term')[0]

    afterEach ->
      Coreon.Helpers.input.restore()

    it 'it adds a new term view', ->
      sinon.stub @view, 'renderTerm'
      sinon.stub Coreon.Models, 'Term'
      @view.$('a.add-term').trigger @event
      expect(Coreon.Models.Term).to.have.been.calledWithNew
      expect(@view.renderTerm).to.have.been.calledOnce

  describe '#removeTerm()', ->

    termView = null

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) -> '<input />'
      termView =
        index: 0
        remove: sinon.spy()
      @view.termViews = [termView]
      @view.$el.append '''
        <fieldset class='term not-persisted' data-index="0">
          <a class='remove-term'>Remove term</a>
        </fieldset
      '''
      @event = $.Event 'click'
      @event.target = @view.$('a.remove-term')[0]

    afterEach ->
      Coreon.Helpers.input.restore()

    it 'is triggered by click on remove action', ->
      @view.removeTerm = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.term a.remove-term').trigger @event
      @view.removeTerm.should.have.been.calledOnce

    it 'removes term', ->
      @event.target = @view.$('.remove-term').get(0)
      @view.removeTerm @event
      expect(termView.remove).to.have.been.calledOnce

  describe '#create()', ->

    beforeEach ->
      @event = $.Event 'submit'
      sinon.stub Backbone.history, 'navigate'
      sinon.stub @view.model, 'save', =>
        @request = $.Deferred()
      sinon.stub @view, 'saveAssets', =>
        @saveAssetsRequest = $.Deferred()
      sinon.stub @view, 'saveTermAssets', =>
        @saveTermAssetsRequest = $.Deferred()
      @view.render()

    afterEach ->
      Backbone.history.navigate.restore()

    it 'is triggered on form submit', ->
      @view.create = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('form').trigger @event
      @view.create.should.have.been.calledOne
      @view.create.should.have.been.calledWith @event

    it 'prevents default action', ->
      @event.preventDefault = sinon.spy()
      @view.create @event
      @event.preventDefault.should.have.been.calledOnce

    it 'updates model from form', ->
      termView =
        index: 0
        serializeArray: ->
          {value: 'foo'}
        serializeAssetsArray: ->
      @view.termViews = [termView]
      @view.editProperties.serializeArray = -> [
        key: 'label'
      ]
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [ key: 'label' ], terms: [ value: 'foo' ]

    it 'deletes empty properties and terms', ->
      @view.termViews = []
      @view.editProperties.serializeArray = -> []
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [], terms: []

    it 'updates nested properties on terms', ->
      @view.editProperties.serializeArray = -> []
      termView =
        index: 0
        serializeArray: ->
          {properties: [key: 'source']}
        serializeAssetsArray: ->
      @view.termViews = [termView]
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [], terms: [ properties: [ key: 'source' ] ]

    context 'success', ->

      beforeEach ->
        Coreon.application = new Backbone.Model
          session:
            currentRepository: -> id: 'coffee23'
        collection = new Backbone.Collection
        sinon.stub Coreon.Models.Concept, 'collection', -> collection
        @view.model.path = -> 'my-repo/concepts/my-concept-123'

      afterEach ->
        Coreon.Models.Concept.collection.restore()

      it 'accumulates newly created model', ->
        @view.model.id = 'babe42'
        @view.create @event
        @request.resolve()
        @saveAssetsRequest.resolve()
        @saveTermAssetsRequest.resolve()
        Coreon.Models.Concept.collection().get('babe42').should.equal @view.model

      it 'redirects to show concept page', ->
        @view.model.id = 'babe42'
        @view.create @event
        @request.resolve()
        @saveAssetsRequest.resolve()
        @saveTermAssetsRequest.resolve()
        Backbone.history.navigate.should.have.been.calledWith(
          'my-repo/concepts/my-concept-123'
        , trigger: true)

      it 'notifies about success', ->
        I18n.t.withArgs('notifications.concept.created').returns 'yay!'
        Coreon.Models.Notification.info = sinon.spy()
        @view.create @event
        @request.resolve()
        @saveAssetsRequest.resolve()
        @saveTermAssetsRequest.resolve()
        Coreon.Models.Notification.info.should.have.been.calledOnce
        Coreon.Models.Notification.info.should.have.been.calledWith 'yay!'

    context 'error', ->

      it 'renders error summary', ->
        @view.create @event
        @view.model.errors = -> {}
        @request.reject()
        @view.$el.should.have 'form .error-summary'

  describe '#cancel()', ->

    app = null

    beforeEach ->
      app = new Backbone.Model
        repository:
          path: -> '/my-repository'
      @view.app = app
      sinon.stub Backbone.history, 'navigate'

    afterEach ->
      Backbone.history.navigate.restore()

    it 'is triggered by click on cancel link', ->
      @view.cancel = sinon.stub().returns false
      @view.delegateEvents()
      @view.$el.html '''
        <a class='cancel'>Cancel</a>
      '''
      @view.$('.cancel').click()
      @view.cancel.should.have.been.calledOnce

    context 'without parent concept', ->

      it 'navigates to repository root page', ->
        @view.cancel()
        Backbone.history.navigate.should.have.been.calledOnce
        Backbone.history.navigate.should.have.been.calledWith '/my-repository'
                                                            , trigger: yes

    context 'with parent concept', ->

      it 'navigates to parent concept', ->
        @view.model.set 'superconcept_ids', ['def345'], silent: yes
        @view.cancel()
        Backbone.history.navigate.should.have.been.calledOnce
        path = '/my-repository/concepts/def345'
        Backbone.history.navigate.should.have.been.calledWith path
                                                            , trigger: yes

  describe '#remove()', ->

    beforeEach ->
      sinon.stub Backbone.View::, 'remove', -> @

    afterEach ->
      Backbone.View::remove.restore()

    it 'can be chained', ->
      @view.remove().should.equal @view

    it 'removes broader and narrower view', ->
      @view.broaderAndNarrower.remove = sinon.spy()
      @view.remove()
      @view.broaderAndNarrower.remove.should.have.been.calledOnce

    it 'calls super implementation', ->
      @view.remove()
      Backbone.View::remove.should.have.been.calledOn @view
