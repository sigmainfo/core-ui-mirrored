#= require spec_helper
#= require application

describe 'Coreon.Application', ->

  app = null
  request = null
  view = null

  fakeSession = (user = {}) ->
    _(user).defaults
      name: ''
      email: ''
    new Backbone.Model user: user

  beforeEach ->
    sinon.stub I18n, 't'
    request = $.Deferred()
    sinon.stub Backbone.history, 'start'
    sinon.stub Coreon.Routers, 'SessionsRouter'
    sinon.stub Coreon.Routers, 'RepositoriesRouter'
    sinon.stub Coreon.Routers, 'ConceptsRouter'
    sinon.stub Coreon.Models.Session, 'load', -> request
    sinon.stub Coreon.Views, 'ApplicationView', ->
      view = new Backbone.View arguments...

    app = new Coreon.Application auth_root: 'https://auth.coreon.com'

  afterEach ->
    I18n.t.restore()
    Backbone.history.start.restore()
    Coreon.Routers.SessionsRouter.restore()
    Coreon.Routers.RepositoriesRouter.restore()
    Coreon.Routers.ConceptsRouter.restore()
    Coreon.Models.Session.load.restore()
    Coreon.Views.ApplicationView.restore()

    delete Coreon.application

  it 'is a Backbone model', ->
    expect(app).to.be.an.instanceOf Backbone.Model

  describe '#defaults', ->

    it 'chooses sensible default for container selector', ->
      el = app.get('el')
      expect(el).to.equal '#coreon-app'

    it 'has no session', ->
      session = app.get('session')
      expect(session).to.be.null

    it 'has no current selection', ->
      selection = app.get('selection')
      expect(selection).to.be.null

    it 'has no repository', ->
      repository = app.get('repository')
      expect(repository).to.be.null

    it 'has index scope', ->
      scope = app.get('scope')
      expect(scope).to.equal 'index'

    it 'is not in edit mode', ->
      editing = app.get('editing')
      expect(editing).to.be.false

    it 'has no query string', ->
      query = app.get('query')
      expect(query).to.equal ''

    it 'has no langs selected', ->
      langs = app.get('langs')
      expect(langs).to.eql []

  describe '#initialize()', ->

    it 'makes instance globally accessible', ->
      instance = Coreon.application
      expect(instance).to.equal app

    it 'enforces single instance', ->
      create = -> new Coreon.Application
      expect(create).to.throw 'Coreon application already initialized'

    it 'creates application view', ->
      constructor = Coreon.Views.ApplicationView
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith
        model: app
        el: '#coreon-app'

    it 'creates sessions router', ->
      constructor = Coreon.Routers.SessionsRouter
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith app

    it 'creates repositories router', ->
      constructor = Coreon.Routers.RepositoriesRouter
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith app

    it 'creates concepts router', ->
      constructor = Coreon.Routers.ConceptsRouter
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith app

  describe '#start()', ->

    it 'can be chained', ->
      result = app.start()
      expect(result).to.equal app

    it 'throws error when no auth root is given', ->
      app.set 'auth_root', '', silent: true
      start = -> app.start()
      expect(start).to.throw 'Authorization service root URL not given'

    it 'configures auth root on session', ->
      app.set 'auth_root', 'https://auth-123.coreon.com'
      app.start()
      authRoot = Coreon.Models.Session.authRoot
      expect(authRoot).to.equal 'https://auth-123.coreon.com'

    it 'loads session', ->
      app.start()
      load = Coreon.Models.Session.load
      expect(load).to.have.been.calledOnce

    it 'assigns session on success', ->
      session = fakeSession()
      app.start()
      request.resolve session
      current = app.get('session')
      expect(current).to.equal session

    it 'clears session on failure', ->
      session = new Backbone.Model
      app.set 'session', session, silent: yes
      app.start()
      request.reject null
      current = app.get('session')
      expect(current).to.be.null

    it 'triggers change event for empty session', ->
      change = sinon.spy()
      app.on 'change:session', change
      app.start()
      request.resolve null
      expect(change).to.have.been.calledOnce
      expect(change).to.have.been.calledWith app, null

  describe '#selectRepository()', ->

    session = null

    beforeEach ->
      session = new Backbone.Model
      session.repositoryById = ->
      app.set 'session', session, silent: yes

    it 'selects repository on session', ->
      app.selectRepository 'my-repo-789'
      id = app.get('session').get('current_repository_id')
      expect(id).to.equal 'my-repo-789'

  describe '#updateRepository()', ->

    repository = null
    session = null
    refresh = null

    beforeEach ->
      session = new Backbone.Model
      repository = new Backbone.Model
      sinon.stub Coreon.Models.RepositorySettings, 'refresh', ->
        always: (callback) -> callback some: 'data'

    afterEach ->
      Coreon.Models.RepositorySettings.refresh.restore()

    context 'triggers', ->

      updateRepository = null

      beforeEach ->
        session = fakeSession()
        updateRepository = sinon.spy()
        app.updateRepository = updateRepository
        app.start()
        app.set 'session', session
        updateRepository.reset()

      it 'is triggered on session change', ->
        app.trigger 'change:session'
        expect(updateRepository).to.have.been.calledOnce
        expect(updateRepository).to.have.been.calledOn app

      it 'is triggered on repository change', ->
        session.trigger 'change:repository'
        expect(updateRepository).to.have.been.calledOnce
        expect(updateRepository).to.have.been.calledOn app

      it 'is only triggered on repository change of current session', ->
        app.set 'session', null
        updateRepository.reset()
        session.trigger 'change:repository'
        expect(updateRepository).to.not.have.been.called

    it 'removes repository if no session exists', ->
      app.set
        repository: repository
        session: null
      , silent: yes
      app.updateRepository()
      current = app.get('repository')
      expect(current).to.be.null

    it 'assigns current repository from session', ->
      session.set 'repository', repository, silent: yes
      app.set
        repository: null
        session: session
      , silent: yes
      app.updateRepository()
      current = app.get('repository')
      expect(current).to.equal repository

    it 'triggers custom event on repository settings load', ->
      repository.id = "FOO"
      session.set 'repository', repository, silent: yes
      app.set
        repository: repository
        session: session
      , silent: yes
      settings = new Backbone.Model
      app.repositorySettings = -> settings
      app.updateRepository()
      trigger = sinon.spy()
      app.on 'change:repositorySettings', trigger
      repository.trigger 'remoteSettingChange'
      expect(trigger).to.have.been.calledOnce
      expect(trigger).to.have.been.calledWith app, settings

  describe '#repository()', ->

    it 'returns current repository from session', ->
      repo = new Backbone.Model
      session = currentRepository: -> repo
      app.set 'session', session, silent: true
      app.repository().should.equal repo

    it 'returns null when no session exists', ->
      app.set 'session', null, silent: yes
      should.equal app.repository(), null

  describe '#watchSession()', ->

    info = null

    beforeEach ->
      info = sinon.stub Coreon.Models.Notification, 'info'

    afterEach ->
      Coreon.Models.Notification.info.restore()

    context 'trigger', ->

      watchSession = null

      beforeEach ->
        watchSession = sinon.stub app, 'watchSession'
        app.start()

      it 'is triggered on sessiojn changes', ->
        app.trigger 'change:session'
        expect(watchSession).to.have.been.calledOnce

    context 'notifications', ->

      it 'creates personalized notification', ->
        session = fakeSession name: 'Nobody'
        I18n.t
          .withArgs('notifications.account.login', name: 'Nobody')
          .returns 'Hello Nobody'
        app.set 'session', session, silent: yes
        app.watchSession()
        expect(info).to.have.been.calledWith 'Hello Nobody'

      it 'does not notify if user has not changed', ->
        previous = fakeSession email: 'me@coreon.com'
        app.set 'session', previous, silent: yes
        current = fakeSession email: 'me@coreon.com'
        app.set 'session', current, silent: yes
        app.watchSession()
        expect(info).to.not.have.been.called

  describe '#langs()', ->

    beforeEach ->
      @repository = usedLanguages: -> []
      app.repositorySettings = => new Backbone.Model
      app.set 'repository', @repository, silent: yes
      app.sourceLang = -> null
      app.targetLang = -> null

    it 'delegates to repository', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      langs = app.langs()
      expect( langs ).to.have.lengthOf 4
      expect( langs ).to.have.include 'en'
      expect( langs ).to.have.include 'hu'
      expect( langs ).to.have.include 'fr'
      expect( langs ).to.have.include 'de'

    it 'sorts languages alphabetically', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      langs = app.langs()
      expect( langs ).to.eql [ 'de', 'en', 'fr', 'hu' ]

    it 'pushes source and destination langs to top', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      app.sourceLang = -> 'fr'
      app.targetLang = -> 'en'
      langs = app.langs()
      expect( langs ).to.eql [ 'fr', 'en', 'de', 'hu' ]

    it 'ignores source and target language when sorting is off', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      app.sourceLang = -> 'fr'
      app.targetLang = -> 'en'
      langs = app.langs ignoreSelection: on
      expect(langs).to.eql [ 'de', 'en', 'fr', 'hu' ]

  describe '#sourceLang()', ->

    beforeEach ->
      @settings = new Backbone.Model
      app.repositorySettings = => @settings

    it 'delegates to repository settings', ->
      @settings.set 'sourceLanguage', 'hu', silent: yes
      lang = app.sourceLang()
      expect( lang ).to.equal 'hu'

    it 'defaults to null', ->
      @settings = null
      lang = app.sourceLang()
      expect( lang ).to.be.null

    it 'returns null for "none"', ->
      @settings.set 'sourceLanguage', 'none', silent: yes
      lang = app.sourceLang()
      expect( lang ).to.be.null

  describe '#targetLang()', ->

    beforeEach ->
      @settings = new Backbone.Model
      app.repositorySettings = => @settings

    it 'delegates to repository settings', ->
      @settings.set 'targetLanguage', 'hu', silent: yes
      lang = app.targetLang()
      expect( lang ).to.equal 'hu'

    it 'defaults to null', ->
      @settings = null
      lang = app.targetLang()
      expect( lang ).to.be.null

    it 'returns null for "none"', ->
      @settings.set 'targetLanguage', 'none', silent: yes
      lang = app.targetLang()
      expect( lang ).to.be.null

  describe '#graphUri()', ->

    it 'returns current graph_uri', ->
      repository = new Backbone.Model graph_uri: 'https://repo123.coreon.com:4000'
      session = currentRepository: -> repository
      app.set 'session', session, silent: yes
      app.graphUri().should.equal 'https://repo123.coreon.com:4000'

    it 'returns null when no current repository exists', ->
      session = currentRepository: -> null
      app.set 'session', session, silent: yes
      should.equal app.graphUri(), null

    it 'returns null when no session exists', ->
      app.set 'session', null, silent: yes
      should.equal app.graphUri(), null

  describe '#lang()', ->

    it 'returns source lang when given', ->
      app.sourceLang = -> 'hu'
      lang = app.lang()
      expect(lang).to.equal 'hu'

    it 'falls back to en', ->
      app.sourceLang = -> null
      lang = app.lang()
      expect(lang).to.equal 'en'
