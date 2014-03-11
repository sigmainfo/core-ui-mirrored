#= require spec_helper
#= require models/repository_cache
#= require models/search

describe 'Creon.Models.Search', ->

  beforeEach ->
    @model = new Coreon.Models.Search

  it 'is a Backbone model', ->
    expect( @model ).to.be.an.instanceof Backbone.Model

  context 'defaults', ->

    it 'has empty result set', ->
      expect( @model.get 'hits' ).to.eql []

    it 'is not done', ->
      expect( @model.get 'done' ).to.be.false

    it 'has no target', ->
      expect( @model.get 'target' ).to.be.null

  describe '#params()', ->

    app = null

    beforeEach ->
      app = new Backbone.Model
      @repositoryCache = new Coreon.Models.RepositoryCache {}
                                                         , app: app

      app.repositorySettings = => @repositoryCache
      Coreon.application = app

      @model.set query: 'gun'

    afterEach ->
      delete Coreon.application

    it 'generates params from data', ->
      @model.set query: 'gun'
      @model.set target: 'terms'
      expect( @model.params() ).to.eql
        'search[query]': 'gun'
        'search[only]':  'terms'
        'search[tolerance]': 2

    it 'skips target when not given', ->
      @model.unset 'target'
      expect( @model.params() ).to.eql
        'search[query]': 'gun'
        'search[tolerance]': 2

    it 'prepends prefixes properties', ->
      @model.set target: 'definition'
      expect( @model.params() ).to.eql
        'search[query]': 'gun'
        'search[only]':  'properties/definition'
        'search[tolerance]': 2

  describe '#sync()', ->

    it 'delegates to core api sync', ->
      expect( @model.sync ).to.equal Coreon.Modules.CoreAPI.sync

  describe '#fetch()', ->

    beforeEach ->
      @deferred = $.Deferred()
      @model.sync = => @deferred.promise()

    it 'sends POST with params', ->
      @model.params = -> 'search[only]': 'terms'
      sinon.spy @model, 'sync'
      @model.fetch parse: yes
      expect( @model.sync ).to.have.been.calledOnce
      expect( @model.sync ).to.have.been.calledWith 'read', @model
      expect( @model.sync.firstCall.args[2] ).to.have.property 'method', 'POST'
      expect( @model.sync.firstCall.args[2] ).to.have.property 'parse', yes
      expect( @model.sync.firstCall.args[2] ).to.have.property 'data'
      expect( @model.sync.firstCall.args[2].data ).to.have.property 'search[only]', 'terms'

    it 'marks search as done', ->
      @model.fetch()
      expect( @model.get 'done' ).to.be.false
      @deferred.resolve()
      expect( @model.get 'done' ).to.be.true

  describe '#query()', ->

    it 'returns query component', ->
      @model.set
        query: 'poetry'
        target: 'terms'
      expect( @model.query() ).to.equal 'terms/poetry'

    it 'skips target when not given', ->
      @model.set query: 'poetry'
      expect( @model.query() ).to.equal 'poetry'

    it 'urlencodes values', ->
      @model.set query: 'foo bar bäz'
      expect( @model.query() ).to.equal 'foo%20bar%20b%C3%A4z'
