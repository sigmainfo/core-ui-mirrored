#= require spec_helper
#= require views/panels/concepts/new_concept_view

describe 'Coreon.Views.Panels.Concepts.NewConceptView', ->

  beforeEach ->
    sinon.stub I18n, 't'
    sinon.stub Coreon.Views.Concepts.Shared, 'BroaderAndNarrowerView', (options) =>
      @broaderAndNarrower = new Backbone.View options
    @view = new Coreon.Views.Panels.Concepts.NewConceptView
      model: new Backbone.Model
        properties: []
        terms: []
        superconcept_ids: []
    @view.model.properties = -> new Backbone.Collection
    @view.model.terms = -> new Backbone.Collection
    @view.model.errors = -> null
    @view.model.propertiesWithDefaults = -> []

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()

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

      properties = (el) ->
        el.find 'section.properties'

      it 'renders container', ->
        @view.render()
        expect(properties @view.$el).to.exist

      it 'renders title', ->
        I18n.t.withArgs('properties.title').returns 'Properties'
        @view.render()
        header = properties(@view.$el).find 'h3'
        expect(header).to.exist
        expect(header).to.have.text 'Properties'

      context 'add property link', ->

        link = (el) ->
          properties(el).find '.add-property'

        it 'renders link for adding a property', ->
          I18n.t.withArgs('properties.add').returns 'Add Property'
          @view.render()
          expect(link @view.$el).to.exist
          expect(link @view.$el).to.have.text 'Add Property'
          expect(link @view.$el).to.have.data 'scope'

        it 'renders next index on link', ->
          @view.model.set 'properties', [ {}, {}, {} ], silent: yes
          @view.render()
          expect(link @view.$el).to.have.data 'index', 3

      context 'fieldset', ->

        propertiesWithDefaults = null
        render = null

        beforeEach ->
          render = sinon.stub Coreon.Helpers, 'render'
          propertiesWithDefaults = sinon.stub @view.model
                                            , 'propertiesWithDefaults'
          propertiesWithDefaults.returns []

        afterEach ->
          Coreon.Helpers.render.restore()

        it 'renders input for each property', ->
          property =
            model: new Backbone.Model
          propertiesWithDefaults.returns [property]
          render.withArgs('properties/property_fieldset'
                        , property: property
                        , index: 0
                        , scope: 'concept[properties][]'
          ).returns '''
            <input name="properties[3]"/>
          '''
          @view.render()
          expect(properties @view.$el).to.have 'input[name="properties[3]"]'

    context 'terms', ->

      beforeEach ->
        @term = new Backbone.Model
        @term.properties = -> models: []
        @term.errors = -> null
        @view.model.terms = => models: []

      it 'renders section with title', ->
        I18n.t.withArgs('terms.title').returns 'Terms'
        @view.render()
        @view.$el.should.have '.terms'
        @view.$el.should.have '.terms h3'
        @view.$('.terms h3').should.have.text 'Terms'

      it 'renders link for adding a term', ->
        I18n.t.withArgs('terms.add').returns 'Add term'
        @view.render()
        @view.$el.should.have 'a.add-term'
        @view.$('a.add-term').should.have.text 'Add term'

      it 'renders inputs for existing terms', ->
        @term.set lang: 'de', silent: true
        @view.model.terms = => models: [ @term ]
        @view.model.errors = ->
          nested_errors_on_terms: [
            value: "can't be blank"
          ]
        @view.render()
        @view.$el.should.have 'form .terms .term .lang input[type="text"]'
        @view.$('form .term .lang input').should.have.value 'de'
        @view.$('form .term .value').should.have '.error-message'
        @view.$('form .term .value .error-message').should.have.text "can't be blank"

      it 'renders link for adding property', ->
        I18n.t.withArgs('properties.add').returns 'Add property'
        @view.model.terms = => models: [ @term ]
        @term.set 'properties', [ key: 'status' ], silent: true
        @view.model.errors = ->
        @view.render()
        @view.$el.should.have 'form .term a.add-property'
        @view.$('form .term a.add-property').should.have.text 'Add property'
        @view.$('form .term a.add-property').should.have.data 'scope', 'concept[terms][0][properties][]'
        @view.$('form .term a.add-property').should.have.data 'index', 1

      it 'renders inputs for term properties', ->
        @term.set 'properties', [ key: 'label' ], silent: true
        @term.properties = -> models: [ new Backbone.Model key: 'label' ]
        @view.model.terms = => models: [ @term ]
        @view.model.errors = ->
          nested_errors_on_terms: [
            nested_errors_on_properties: [
              value: [ "can't be blank" ]
            ]
          ]
        @view.render()
        @view.$el.should.have 'form .terms .term .property .key input[type="text"]'
        @view.$('form .term .property .key input').should.have.value 'label'
        @view.$('form .term .property .key input').should.have.attr 'name', 'concept[terms][0][properties][0][key]'
        @view.$('form .term .property .value').should.have '.error-message'
        @view.$('form .term .property .value .error-message').should.have.text "can't be blank"

  describe '#addProperty()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) ->
        "<input id='#{name}-#{options.index}-#{attr}' name='#{options.scope}[#{attr}]' #{'required' if options.required}/>"
      @event = $.Event 'click'
      @view.render()
      $('#konacha').append @view.$el
      @event.target = @view.$('.add-property').get(0)

    afterEach ->
      Coreon.Helpers.input.restore()

    it 'is triggered by click on action', ->
      @view.addProperty = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('a.add-property').trigger @event
      @view.addProperty.should.have.been.calledOnce
      @view.addProperty.should.have.been.calledWith @event

    it 'appends property input set', ->
      @view.addProperty @event
      @view.$el.should.have '.properties .property input[id="property-0-key"]'
      @view.$el.should.have '.properties .property input[id="property-0-value"]'
      @view.$el.should.have '.properties .property input[id="property-0-lang"]'

    it 'enumerates appended property input sets', ->
      @view.$('a.add-property').attr 'data-index', 5
      @view.addProperty @event
      @view.addProperty @event
      @view.$el.should.have '.properties .property input[id="property-5-key"]'
      @view.$el.should.have '.properties .property input[id="property-6-key"]'

    it 'uses nested scope', ->
      @view.addProperty @event
      @view.$el.should.have '.properties .property input[name="concept[properties][][key]"]'
      @view.$el.should.have '.properties .property input[name="concept[properties][][value]"]'
      @view.$el.should.have '.properties .property input[name="concept[properties][][lang]"]'

    it 'requires key and value inputs', ->
      @view.addProperty @event
      @view.$('.properties .property input[id="property-0-key"]').should.have.attr 'required'
      @view.$('.properties .property input[id="property-0-value"]').should.have.attr 'required'
      @view.$('.properties .property input[id="property-0-lang"]').should.not.have.attr 'required'

    it 'renders remove link', ->
      I18n.t.withArgs('property.remove').returns 'Remove property'
      @view.addProperty @event
      @view.$el.should.have '.property a.remove-property'
      @view.$('.property a.remove-property').should.have.text 'Remove property'

  describe '#removeProperty()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) -> '<input />'
      @event = $.Event 'click'
      @view.render()
      @view.$('.properties').append '''
        <fieldset class='property not-persisted'>
          <a class='remove-property'>Remove property</a>
        </fieldset>
        '''

    afterEach ->
      Coreon.Helpers.input.restore()

    it 'is triggered by click on remove action', ->
      @view.removeProperty = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.property a.remove-property').trigger @event
      @view.removeProperty.should.have.been.calledOnce

    it 'removes property input set', ->
      @event.target = @view.$('.remove-property').get(0)
      @view.removeProperty @event
      @view.$el.should.not.have '.property'

  describe '#addTerm()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) ->
        "<input id='#{name}-#{options.index}-#{attr}' name='#{options.scope}[#{attr}]' #{'required' if options.required}/>"
      @view.render()
      @event = $.Event 'click'
      @event.target = @view.$('a.add-term')[0]

    afterEach ->
      Coreon.Helpers.input.restore()

    it 'is triggered by click on action', ->
      @view.addTerm = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('a.add-term').trigger @event
      @view.addTerm.should.have.been.calledOnce
      @view.addTerm.should.have.been.calledWith @event

    it 'appends term input set', ->
      @view.addTerm @event
      @view.$el.should.have '.terms .term input[id="term-0-value"]'
      @view.$el.should.have '.terms .term input[id="term-0-lang"]'

    it 'enumerates appended term input sets', ->
      @view.model.set 'terms', [{}, {}], silent: true
      @view.render()
      @event.target = @view.$('a.add-term')[0]
      @view.addTerm @event
      @view.addTerm @event
      @view.$el.should.have '.terms .term input[id="term-2-value"]'
      @view.$el.should.have '.terms .term input[id="term-3-value"]'

    it 'uses nested scope', ->
      @view.addTerm @event
      @view.$el.should.have '.terms .term input[name="concept[terms][][value]"]'
      @view.$el.should.have '.terms .term input[name="concept[terms][][lang]"]'

    it 'requires key and value inputs', ->
      @view.addTerm @event
      @view.$('.terms .term input[id="term-0-value"]').should.have.attr 'required'
      @view.$('.terms .term input[id="term-0-lang"]').should.have.attr 'required'

    it 'renders remove link', ->
      I18n.t.withArgs('term.delete').returns 'Remove term'
      @view.addTerm @event
      @view.$el.should.have '.term a.remove-term'
      @view.$('.term a.remove-term').should.have.text 'Remove term'

  describe '#removeTerm()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'input', (name, attr, model, options) -> '<input />'
      @view.$el.append '''
        <fieldset class='term not-persisted'>
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

    it 'removes term input set', ->
      @event.target = @view.$('.remove-term').get(0)
      @view.removeTerm @event
      @view.$el.should.not.have '.term'

  describe '#create()', ->

    beforeEach ->
      @event = $.Event 'submit'
      sinon.stub Backbone.history, 'navigate'
      sinon.stub @view.model, 'save', =>
        @request = $.Deferred()
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
      @view.$('.properties').append '<input name="concept[properties][0][key]" value="label"/>'
      @view.$('.terms').append '<input name="concept[terms][0][value]" value="foo"/>'
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [ key: 'label' ], terms: [ value: 'foo' ]

    it 'deletes empty properties and terms', ->
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [], terms: []

    it 'updates nested properties on terms', ->
      @view.$('.terms').append '<input name="concept[terms][0][properties][0][key]" value="source"/>'
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [], terms: [ properties: [ key: 'source' ] ]

    it 'does not set deleted properties', ->
      @view.$('.properties').append '<input name="concept[properties][2][key]" value="label"/>'
      @view.$('.terms').append '<input name="concept[terms][1][value]" value="foo"/>'
      @view.create @event
      @view.model.save.should.have.been.calledWith properties: [ key: 'label' ], terms: [ value: 'foo' ]

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
        Coreon.Models.Concept.collection().get('babe42').should.equal @view.model

      it 'redirects to show concept page', ->
        @view.model.id = 'babe42'
        @view.create @event
        @request.resolve()
        Backbone.history.navigate.should.have.been.calledWith(
          'my-repo/concepts/my-concept-123'
        , trigger: true)

      it 'notifies about success', ->
        I18n.t.withArgs('notifications.concept.created').returns 'yay!'
        Coreon.Models.Notification.info = sinon.spy()
        @view.create @event
        @request.resolve()
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
