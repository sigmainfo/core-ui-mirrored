#= require spec_helper
#= require models/concept

describe 'Coreon.Models.Concept', ->

  application = null

  buildApplication = ->
    new Backbone.Model langs: []

  beforeEach ->
    @hits = new Backbone.Collection
    @hits.findByResult = -> null
    @stub Coreon.Collections.Hits, 'collection', => @hits
    application = buildApplication()
    @model = new Coreon.Models.Concept {}, app: application

  it 'is a Backbone model', ->
    expect( @model ).to.been.an.instanceof Backbone.Model

  it 'is an accumulating model', ->
    expect( Coreon.Models.Concept.find ).to.equal Coreon.Modules.Accumulation.find

  it 'uses Concepts collection for accumulation', ->
    collection = Coreon.Models.Concept.collection()
    expect( collection ).to.be.an.instanceof Coreon.Collections.Concepts
    expect( Coreon.Models.Concept.collection() ).to.equal collection

  it 'has an URL root', ->
    expect( @model.urlRoot ).to.equal '/concepts'

  context 'defaults', ->

    it 'has an empty set for relations', ->
      expect( @model.get('properties') ).to.eql []
      expect( @model.get('terms') ).to.eql []

    it 'has empty sets for superconcept and subconcept ids', ->
      expect( @model.get('superconcept_ids') ).to.eql []
      expect( @model.get('subconcept_ids') ).to.eql []

  describe '#initialize()', ->

    afterEach ->
      delete Coreon.application

    it 'assigns app from options', ->
      app2 = new Backbone.Model
      @model.initialize null, app: app2
      assigned = @model.app
      expect(assigned).to.equal app2

    it 'defaults app to global reference', ->
      app2 = new Backbone.Model
      Coreon.application = app2
      @model.initialize()
      assigned = @model.app
      expect(assigned).to.equal app2

  describe '#updateLabel()', ->

    context 'triggers', ->

      updateLabel = null

      beforeEach ->
        # TODO 140512 [tc] replace assignments with local vars
        updateLabel = @stub @model, 'updateLabel'
        @model.initialize null, app: application
        updateLabel.reset()

      it 'is called silently on initialize', ->
        @model.initialize null, app: application
        expect(updateLabel).to.have.been.calledOnce
        expect(updateLabel).to.have.been.calledWith @model, silent: yes

      it 'is triggered on term changes', ->
        @model.trigger 'change:terms'
        expect(updateLabel).to.have.been.calledOnce

      it 'is triggered on property changes', ->
        @model.trigger 'change:properties'
        expect(updateLabel).to.have.been.calledOnce

      it 'is triggered on id changes', ->
        @model.trigger 'change:id'
        expect(updateLabel).to.have.been.calledOnce

      it 'is triggered on change of selected langs', ->
        application.trigger 'change:langs'
        expect(updateLabel).to.have.been.calledOnce

    context 'options', ->

      it 'can be silenced', ->
        @model.set 'label', 'foo', silent: yes
        callback = @spy()
        @model.on 'change:label', callback
        @model.updateLabel @model, silent: yes
        expect(callback).to.not.have.been.called

    context 'new', ->

      beforeEach ->
        @model.isNew = -> yes

      it 'creates placeholder label', ->
        I18n.t.withArgs('concept.new_concept').returns '<new concept>'
        @model.updateLabel()
        label = @model.get 'label'
        expect(label).to.equal '<new concept>'

    context 'persisted', ->

      label = (model) -> model.get 'label'

      beforeEach ->
        @model.isNew = -> no

      it 'takes value from preferred term', ->
        term = new Backbone.Model value: 'My Concept'
        @model.preferredTerm = -> term
        @model.updateLabel()
        expect(label @model).to.equal 'My Concept'

      it 'uses id as a fallback', ->
        @model.id = 'c123abcdef'
        @model.updateLabel()
        expect(label @model).to.equal 'c123abcdef'

      it 'is shadowed by label property', ->
        property = new Backbone.Model value: 'No. 123'
        @model.propertiesByKey = -> [
          key: 'label', properties: [property]
        ]
        @model.updateLabel()
        expect(label @model).to.equal 'No. 123'

  describe 'attributes', ->

    describe 'hit', ->

      beforeEach ->
        @hits.add id: 'hit', result: @model
        @hit = @hits.at 0
        @hits.findByResult = (result) =>
          for hit in @hits.models
            return hit if hit.get('result') is result
          null
        @model.initialize null, app: application

      it 'gets hit from id', ->
        expect( @model.get('hit') ).to.equal @hit

      it 'updates hit on reset', ->
        @hits.reset []
        expect(@model.get 'hit').to.be.null

      it 'updates hit on remove', ->
        @hits.remove @hit
        expect(@model.get 'hit').to.be.null

      it 'updates hit when added', ->
        other = new Backbone.Model
        @hits.add result: other
        added = hit for hit in @hits.models when hit.get('result') is @model
        expect( @model.get('hit') ).to.equal added

  describe '.roots()', ->

    beforeEach ->
      Coreon.application =
        graphUri: -> 'https://api.coreon.com/123/'
      @collection = new Backbone.Collection
      @stub Coreon.Models.Concept, 'collection', =>
        @collection
      @stub Coreon.Modules.CoreAPI, 'sync', =>
        @request = $.Deferred()
        @request.promise()

    afterEach ->
      delete Coreon.application

    it 'fetches root concept ids thru API call', ->
      request = Coreon.Models.Concept.roots()
      sync = Coreon.Modules.CoreAPI.sync
      expect( sync ).to.have.been.calledOnce
      expect( sync ).to.have.been.calledWith "read", @collection
      options = sync.firstCall.args[2]
      expect( options ).to.have.property 'url',
        'https://api.coreon.com/123/concepts/roots'
      expect( options ).to.not.have.property 'batch'
      expect( request ).to.equal @request.promise()

  describe '#preferredTerm()', ->

    term = null
    terms = null

    beforeEach ->
      term = new Backbone.Model
      terms = new Backbone.Collection []
      @model.terms = -> terms

    it 'defaults to first term', ->
      terms.reset [term]
      preferred = @model.preferredTerm()
      expect(preferred).to.equal term

    it 'takes first term in source lang when set', ->
      term2 = new Backbone.Model lang: 'de'
      application.set 'langs', ['de'], silent: yes
      terms.reset [term, term2]
      preferred = @model.preferredTerm()
      expect(preferred).to.equal term2

    it 'falls back to first term in target lang when source not available', ->
      term2 = new Backbone.Model lang: 'de'
      application.set 'langs', ['en', 'de'], silent: yes
      terms.reset [term, term2]
      preferred = @model.preferredTerm()
      expect(preferred).to.equal term2

    it 'falls back to first term in target lang when others not available', ->
      term2 = new Backbone.Model lang: 'en'
      application.set 'langs', ['hu', 'de'], silent: yes
      terms.reset [term, term2]
      preferred = @model.preferredTerm()
      expect(preferred).to.equal term2

    it 'normalizes lang for detection', ->
      term2 = new Backbone.Model lang: 'DE_AT'
      application.set 'langs', ['hu', 'de'], silent: yes
      terms.reset [term, term2]
      preferred = @model.preferredTerm()
      expect(preferred).to.equal term2

  describe '#properties()', ->

    it 'syncs with attr', ->
      @model.set 'properties', [key: 'label']
      expect( @model.properties().at(0) ).to.be.an.instanceof Coreon.Models.Property
      expect( @model.properties().at(0).get('key') ).to.equal 'label'

  describe '#terms()', ->

    it 'creates terms from attr', ->
      @model.set 'terms', [value: 'dead', lang: 'en']
      expect( @model.terms().at(0) ).to.be.an.instanceof Coreon.Models.Term
      expect( @model.terms().at(0).get('value') ).to.equal 'dead'

    it 'updates attr from terms', ->
      @model.terms().reset [ value: 'dead', lang: 'en', properties: [] ]
      expect( @model.get('terms') ).to.eql [ value: 'dead', lang: 'en', properties: [] ]

  describe '#info()', ->

    it 'returns hash with system info attributes', ->
      @model.set {
        id: 'abcd1234'
        admin: {author: 'Nobody'}
        terms : [ 'foo', 'bar' ]
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'
      }, silent: true
      expect( @model.info() ).to.eql
        id: 'abcd1234'
        author: 'Nobody'
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'

  describe '#toJSON()', ->

    it 'returns wrapped attributes hash', ->
      @model.set
        id: 'my-concept'
        superconcept_ids: [ 'super_1', 'super_2' ]
        subconcept_ids: [ 'sub_1', 'sub_2' ]
      json = @model.toJSON()
      expect( json ).to.have.deep.property 'concept.id', 'my-concept'
      expect( json ).to.have.deep.property('concept.superconcept_ids').that.eql [ 'super_1', 'super_2' ]
      expect( json ).to.have.deep.property('concept.subconcept_ids').that.eql [ 'sub_1', 'sub_2' ]

    it 'drops client-side attributes', ->
      expect( @model.toJSON() ).to.not.have.deep.property 'concept.label'
      expect( @model.toJSON() ).to.not.have.deep.property 'concept.hit'

    it 'does not create wrapper for terms', ->
      @model.terms().reset [ { value: 'hat' }, { value: 'top hat' } ]
      expect( @model.toJSON() ).to.have.deep.property 'concept.terms[0].value', 'hat'
      expect( @model.toJSON() ).to.have.deep.property 'concept.terms[1].value', 'top hat'

  describe '#fetch()', ->

      beforeEach ->
        @stub Coreon.Modules.CoreAPI, 'sync'

      it 'combines multiple subsequent calls into a single batch request', ->
        @model.fetch()
        expect( Coreon.Modules.CoreAPI.sync ).to.have.been.calledOnce
        expect( Coreon.Modules.CoreAPI.sync.firstCall.args[2] ).to.have.property 'batch', on

  describe '#save()', ->

    context 'application sync', ->

      beforeEach ->
        @stub Coreon.Modules.CoreAPI, 'sync'

      it 'delegates to application sync', ->
        @model.isNew = -> false
        @model.save {}, wait: true
        expect( Coreon.Modules.CoreAPI.sync ).to.have.been.calledOnce
        expect( Coreon.Modules.CoreAPI.sync ).to.have.been.calledWith 'update', @model
        expect( Coreon.Modules.CoreAPI.sync.firstCall.args[2] ).to.have.property 'wait', true

    context 'create', ->

      beforeEach ->
        @model.id = null
        @stub Coreon.Modules.CoreAPI, 'sync', (method, model, options = {}) ->
          model.id = '1234'
          options.success?()

      it 'triggers custom event', ->
        spy = @spy()
        @model.on 'create', spy
        @model.save 'label', 'dead man'
        @model.save 'label', 'nobody'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledWith @model, @model.id

  describe '#errors()', ->

    it 'collects remote validation errors', ->
      @model.trigger 'error', @model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      expect( @model.errors() ).to.eql
        foo: ['must be bar']

  describe '#revert()', ->

    it 'can restore last persisted state', ->
      @model.set 'label', 'high hat', silent: true
      @model.trigger 'sync'
      @model.set 'label', 'xxxx', silent: true
      @model.set 'label', '****', silent: true
      @model.revert()
      expect( @model.get('label') ).to.equal 'high hat'


  describe '#acceptsConnection()', ->
    beforeEach ->
      @model.id = 'c0ffee'
      @model.set 'subconcept_ids', ['bad1dea'], silent: true
      @model.set 'superconcept_ids', ['deadbeef'], silent: true

    it 'forbids simple circular connections', ->
      expect( @model.acceptsConnection('c0ffee') ).to.be.false
      expect( @model.acceptsConnection('bad1dea') ).to.be.false
      expect( @model.acceptsConnection('deadbeef') ).to.be.false

    it 'allows valid connections', ->
      expect( @model.acceptsConnection('f00baa') ).to.be.true

  describe '#path()', ->

    beforeEach ->
      Coreon.application =
        repositorySettings: ->

    afterEach ->
      delete Coreon.application

    it 'composes path from repository and id', ->
      Coreon.application = repository: ->
        path: -> '/hjkl9876'
      @model.id = '1234sdfg'
      expect( @model.path() ).to.equal '/hjkl9876/concepts/1234sdfg'

    it 'returns null path for new model', ->
      @model.isNew = -> true
      expect( @model.path() ).to.equal 'javascript:void(0)'

  describe '#broader()', ->

    sorted = null

    beforeEach ->
      @stub Coreon.Models.Concept, 'find'
      @stub Coreon.Modules.Collation, 'sortBy', ->
        sorted = @.slice()

    it 'returns a set containing the superconcepts', ->
      parent = new Backbone.Model
      @model.set 'superconcept_ids', [ 'p12345' ], silent: yes
      Coreon.Models.Concept.find.withArgs('p12345').returns parent
      expect( @model.broader() ).to.eql [ parent ]

  describe '#definition()', ->

    it 'returns null when no definition is given', ->
      @model.propertiesByKey = -> []
      definition = @model.definition()
      expect(definition).to.be.null

    it 'returns first definition in preferred lang', ->
      property = new Backbone.Model value: 'A rose is a rose.'
      @model.propertiesByKey = -> [
        key: 'definition', properties: [property]
      ]
      definition = @model.definition()
      expect(definition).to.equal 'A rose is a rose.'
