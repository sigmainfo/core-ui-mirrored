#= require spec_helper
#= require models/term

describe 'Coreon.Models.Term', ->

  model = null

  beforeEach ->
    @stub I18n, 't'
    model = new Coreon.Models.Term

  it 'is a Backbone model', ->
    model.should.been.an.instanceof Backbone.Model

  context 'defaults', ->

    it 'has an empty set of properties', ->
      model.get('properties').should.eql []

    it 'has an empty value attribure', ->
      model.get('value').should.eql ''

    it 'has an empty lang attribure', ->
      model.get('lang').should.eql ''

    it 'has an empty concept_id attribure', ->
      model.get('lang').should.eql ''

  describe '#urlRoot()', ->

    it 'is constructed from concept id', ->
      model.set 'concept_id', '4567asdf'
      model.urlRoot().should.equal '/concepts/4567asdf/terms'

  describe '#toJSON()', ->

    it 'wraps term', ->
      model.set 'value', 'foo', silent: true
      model.toJSON().should.have.deep.property 'term.value', 'foo'

    it 'skips concept_id', ->
      model.toJSON().term.should.not.have.property 'concept_id'

  describe '#properties()', ->

    it 'syncs with attr', ->
      model.set 'properties', [key: 'label']
      model.properties().at(0).should.be.an.instanceof Coreon.Models.Property
      model.properties().at(0).get('key').should.equal 'label'

  describe '#info()', ->

    it 'returns hash with system info attributes', ->
      model.set {
        id: 'abcd1234'
        admin: {author: 'Nobody'}
        properties : [ 'foo', 'bar' ]
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'
      }, silent: true
      model.info().should.eql
        id: 'abcd1234'
        author: 'Nobody'
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'

  describe '#propertiesByKey()', ->

    it 'delegates to module', ->
      method = Coreon.Modules.Properties.propertiesByKey
      propertiesByKey = model.propertiesByKey
      expect(propertiesByKey).to.exist
      expect(propertiesByKey).to.equal method


  describe '#save()', ->

    beforeEach ->
      Coreon.application = graphUri:-> '/coffee23'
      @stub Coreon.Modules.CoreAPI, 'sync', (method, model, options = {}) ->
        model.id = '1234'
        options.success?()

    it 'triggers custom event', ->
      spy = @spy()
      model.on 'create', spy
      model.save 'value', 'high hat'
      model.save 'value', 'beaver hat'
      spy.should.have.been.calledOnce
      spy.should.have.been.calledWith model, model.id

  describe '#errors()', ->

    it 'collects remote validation errors', ->
      model.trigger 'error', model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      model.errors().should.eql
        foo: ['must be bar']


  describe '#revert()', ->

    it 'restores persisted state', ->
      model.set 'value', 'hat', silent: true
      model.trigger 'sync'
      model.set 'value', '####', silent: true
      model.set 'value', '****', silent: true
      model.revert()
      model.get('value').should.equal 'hat'

    it 'restores initial state', ->
      model.set 'value', 'hat', silent: true
      model.initialize()
      model.set 'value', '####', silent: true
      model.set 'value', '****', silent: true
      model.revert()
      model.get('value').should.equal 'hat'

  describe '#conceptPath()', ->

    beforeEach ->
      repository = path: -> '/'
      Coreon.application = repository: -> repository

    afterEach ->
      delete Coreon.application

    it 'returns path to parent concept', ->
      Coreon.application.repository().path = -> '/my-repo'
      model.set 'concept_id', 'my-concept-123', silent: yes
      expect( model.conceptPath() ).to.equal '/my-repo/concepts/my-concept-123'

  describe '#publicProperties()', ->

    properties = null

    beforeEach ->
      properties = new Backbone.Collection
      model.properties = -> properties

    it 'creates a collection', ->
      publicProperties = model.publicProperties()
      expect(publicProperties).to.be.an.instanceOf Backbone.Collection

    it 'fills collection with current models', ->
      property = new Backbone.Model
      properties.reset [property], silent: yes
      publicProperties = model.publicProperties()
      models = publicProperties.models
      expect(models).to.eql [property]

    it 'filters out precedence from models', ->
      property1 = new Backbone.Model key: 'author', value: 'Nobody'
      property2 = new Backbone.Model key: 'precedence', value: '9'
      properties.reset [property1, property2], silent: yes
      publicProperties = model.publicProperties()
      models = publicProperties.models
      expect(models).to.eql [property1]
