#= require spec_helper
#= require collections/terms

describe 'Coreon.Collections.Terms', ->

  collection = null

  beforeEach ->
    collection = new Coreon.Collections.Terms

  it 'is a backbone collection', ->
    collection.should.be.an.instanceof Backbone.Collection

  it 'creates Term models', ->
    collection.add id: 'term'
    collection.get('term').should.be.an.instanceof Coreon.Models.Term

  describe '.hits()', ->

    beforeEach ->
      @hits = new Backbone.Collection
      sinon.stub Coreon.Collections.Hits, 'collection', => @hits
      collection = Coreon.Collections.Terms.hits()

    afterEach ->
      Coreon.Collections.Terms._hits = null
      Coreon.Collections.Hits.collection.restore()

    it 'creates instance', ->
      expect( collection ).to.be.an.instanceof Coreon.Collections.Terms
      expect( collection ).to.have.lengthOf 0

    it 'ensures single instance', ->
      expect( Coreon.Collections.Terms.hits() ).to.equal collection

    it 'updates itself from hits', ->
      collection.reset [
        value: 'old', lang: 'en'
      ], silent: yes

      concept1 = new Backbone.Model
      concept1.terms = -> new Backbone.Collection [
        new Coreon.Models.Term value: 'Billiard' , lang: 'de'
        new Coreon.Models.Term value: 'billiards', lang: 'en'
      ]
      concept2 = new Backbone.Model
      concept2.terms = -> new Backbone.Collection [
        new Coreon.Models.Term value: 'Queue', lang: 'de'
      ]
      concept3 = new Backbone.Model
      concept3.terms = -> new Backbone.Collection []

      @hits.reset [
        { result: concept1 }
        { result: concept2 }
        { result: concept3 }
      ], silent: yes
      @hits.trigger 'update'
      expect( collection ).to.have.lengthOf 3
      term1 = collection.findWhere { value: 'Billiard' , lang: 'de' }
      expect( term1 ).to.exist
      term2 = collection.findWhere { value: 'billiards', lang: 'en' }
      expect( term2 ).to.exist
      term3 = collection.findWhere { value: 'Queue'    , lang: 'de' }
      expect( term3 ).to.exist

    it 'updates itself when terms on hit change', ->
      concept = new Backbone.Model
      concept.terms = -> new Backbone.Collection [
        new Coreon.Models.Term value: 'Billiard' , lang: 'de'
      ]
      @hits.reset [ result: concept ], silent: yes
      @hits.trigger 'update'
      concept.terms = -> new Backbone.Collection [
        new Coreon.Models.Term value: 'Foo' , lang: 'de'
      ]
      concept.trigger 'change:terms'
      expect( collection ).to.have.lengthOf 1
      term = collection.at 0
      expect( term.get 'value' ).to.equal 'Foo'

  describe '#comparator()', ->

    it 'sorts by precedence', ->
      collection.reset [
        { value: 'Billiard', properties: [ key: 'precedence', value: 3 ] }
        { value: 'Cue'     , properties: [ key: 'precedence', value: 1 ] }
        { value: 'Queue'   , properties: [ key: 'precedence', value: 2 ] }
      ]
      values = collection.pluck 'value'
      expect(values).to.eql ['Cue', 'Queue', 'Billiard']

    it 'appends terms that have no precedence set', ->
      collection.reset [
        { value: 'Billiard', properties: [ key: 'precedence', value: 3 ] }
        { value: 'Cue'     , properties: [] }
        { value: 'Queue'   , properties: [ key: 'precedence', value: 2 ] }
      ]
      values = collection.pluck 'value'
      expect(values).to.eql ['Queue', 'Billiard', 'Cue']

    it 'sorts by sort key when precedence is equal', ->
      collection.reset [
        { value: 'Billiard', sort_key: '29373d3d3727492d010c018f'
        , properties: [ key: 'precedence', value: 2 ] }
        { value: 'Queue'   , sort_key: '474f2f4f2f0109018f08'
        , properties: [ key: 'precedence', value: 2 ] }
        { value: 'Cue'     , sort_key: '2b4f2f0107018f06'
        , properties: [ key: 'precedence', value: 2 ] }
      ]
      values = collection.pluck 'value'
      expect(values).to.eql ['Billiard', 'Cue', 'Queue']

  describe '#lang()', ->

    it 'filters terms by given lang', ->
      collection.reset [
        { lang: 'en', value: 'Billiards' }
        { lang: 'de', value: 'Queue'     }
        { lang: 'en', value: 'Cue'       }
      ]
      en = collection.lang 'en'
      values = en.map (term) -> term.get 'value'
      expect( values ).to.contain 'Billiards', 'Cue'
      expect( values ).to.not.contain 'Queue'

  describe '#langs()', ->

    it 'returns a unique list of used langs', ->
      collection.reset [
        {lang: 'en'}
        {lang: 'de'}
        {lang: 'en'}
        {lang: 'el'}
      ], silent: yes
      langs = collection.langs()
      expect(langs).to.eql ['en', 'de', 'el']

  describe '#hasProperties()', ->

    term1 = null
    term2 = null

    beforeEach ->
      collection.reset [
        {value: 'foo'}
        {value: 'bar'}
      ], silent: yes
      [term1, term2] = collection.models
      term1.hasProperties = -> no
      term2.hasProperties = -> no

    it 'is true when any term has properties', ->
      term1.hasProperties = -> no
      term2.hasProperties = -> yes
      hasProperties = collection.hasProperties()
      expect(hasProperties).to.be.true

    it 'is false when no term has any properties', ->
      term1.hasProperties = -> no
      term2.hasProperties = -> no
      hasProperties = collection.hasProperties()
      expect(hasProperties).to.be.false

  describe '#toJSON()', ->

    it 'strips wrapping objects from terms', ->
      collection.reset [ value: 'high hat', lang: 'de', properties: [] ]
      collection.toJSON().should.eql [
        value: 'high hat', lang: 'de', properties: []
      ]

  describe '#url()', ->

    it 'combines graph uri and path', ->
      Coreon.application = graphUri: -> 'core.api/'
      expect( collection.url() ).to.equal 'core.api/terms'


  describe '#fetch()', ->

    beforeEach ->
      sinon.stub Backbone.Collection::, 'fetch'

    afterEach ->
      Backbone.Collection::fetch.restore()

    it 'raises exception when no lang is given', ->
      expect( => collection.fetch() ).to.throw 'No language given'

    it 'overrides url for syncing', ->
      collection.url = -> 'core.api/terms'
      collection.fetch 'de'
      backboneFetch = Backbone.Collection::fetch
      expect( backboneFetch ).to.have.been.calledOnce
      expect( backboneFetch ).to.have.been.calledWith
        url: 'core.api/terms/list/de/asc'

    it 'includes order in generated url', ->
      collection.url = -> 'core.api/terms'
      collection.fetch 'de', order: 'desc'
      backboneFetch = Backbone.Collection::fetch
      expect( backboneFetch ).to.have.been.calledOnce
      expect( backboneFetch ).to.have.been.calledWith
        url: 'core.api/terms/list/de/desc'

    it 'escapes lang', ->
      collection.url = -> 'core.api/terms'
      collection.fetch 'dänisch/DK'
      backboneFetch = Backbone.Collection::fetch
      expect( backboneFetch ).to.have.been.calledWith
        url: 'core.api/terms/list/d%C3%A4nisch%2FDK/asc'

    it 'returns deferred', ->
      backboneFetch = Backbone.Collection::fetch
      deferred = $.Deferred()
      backboneFetch.returns deferred
      expect( collection.fetch 'de' ).to.equal deferred

    it 'can request a range', ->
      collection.url = -> 'core.api/terms'
      collection.fetch 'de', from: '1234abcdef', order: 'desc'
      backboneFetch = Backbone.Collection::fetch
      expect( backboneFetch ).to.have.been.calledOnce
      expect( backboneFetch ).to.have.been.calledWith
        url: 'core.api/terms/list/de/desc/1234abcdef'

  describe '#sync()', ->

    beforeEach ->
      sinon.stub Coreon.Modules.CoreAPI, 'sync'

    afterEach ->
      Coreon.Modules.CoreAPI.sync.restore()

    it 'delegates to API sync', ->
      collection.sync 'read', collection, url: 'terms/de'
      apiSync = Coreon.Modules.CoreAPI.sync
      expect( apiSync ).to.have.been.calledOnce
      expect( apiSync ).to.have.been.calledWith 'read'
                                              , collection
                                              , url: 'terms/de'
