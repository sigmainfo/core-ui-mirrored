#= require spec_helper
#= require models/repository_cache

describe 'Coreon.Models.RepositoryCache', ->

  app = null
  cache = null

  beforeEach ->
    app = new Backbone.Model
    cache = new Coreon.Models.RepositoryCache {}
                                            , app: app

  it 'is a Backbone model', ->
    expect(cache).to.be.an.instanceOf Backbone.Model

  describe '#initialize()', ->

    it 'assigns app', ->
      assigned = cache.app
      expect(assigned).to.equal app

  describe '#updateLangs()', ->

    context 'triggers', ->

      updateLangs = null

      beforeEach ->
        updateLangs = sinon.spy()
        cache.updateLangs = updateLangs
        cache.initialize {}, app: app
        updateLangs.reset()

      it 'is triggered on init', ->
        cache.initialize()
        expect(updateLangs).to.have.been.calledOnce
        expect(updateLangs).to.have.been.calledOn cache

      it 'is triggered by change of source lang', ->
        cache.trigger 'change:sourceLanguage'
        expect(updateLangs).to.have.been.calledOnce
        expect(updateLangs).to.have.been.calledOn cache

      it 'is triggered by change of target lang', ->
        cache.trigger 'change:targetLanguage'
        expect(updateLangs).to.have.been.calledOnce
        expect(updateLangs).to.have.been.calledOn cache

    context 'updating app', ->

      it 'defaults to empty list', ->
        cache.set
          sourceLanguage: null
          targetLanguage: null
        , silent: yes
        cache.updateLangs()
        langs = app.get('langs')
        expect(langs).to.eql []

      it 'sets source and target lang on app', ->
        cache.set
          sourceLanguage: 'en'
          targetLanguage: 'de'
        , silent: yes
        cache.updateLangs()
        langs = app.get('langs')
        expect(langs).to.eql ['en', 'de']

      it 'skips empty value for target', ->
        cache.set
          sourceLanguage: 'en'
          targetLanguage: null
        , silent: yes
        cache.updateLangs()
        langs = app.get('langs')
        expect(langs).to.eql ['en']

      it 'skips empty value for source', ->
        cache.set
          sourceLanguage: null
          targetLanguage: 'de'
        , silent: yes
        cache.updateLangs()
        langs = app.get('langs')
        expect(langs).to.eql ['de']

