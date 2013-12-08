#= require spec_helper
#= require application

describe 'Coreon.Application', ->

  beforeEach ->
    @request = $.Deferred()
    sinon.stub Backbone.history, 'start'
    sinon.stub Coreon.Routers, 'SessionsRouter'
    sinon.stub Coreon.Routers, 'RepositoriesRouter'
    sinon.stub Coreon.Routers, 'ConceptsRouter'
    #sinon.stub Coreon.Routers, 'SearchRouter'
    sinon.stub Coreon.Models.Session, 'load', => @request
    sinon.stub Coreon.Views, 'ApplicationView', =>
      @view = new Backbone.View arguments...
    @app = new Coreon.Application auth_root: 'https://auth.coreon.com'

  afterEach ->
    Backbone.history.start.restore()
    Coreon.Routers.SessionsRouter.restore()
    Coreon.Routers.RepositoriesRouter.restore()
    Coreon.Routers.ConceptsRouter.restore()
    #Coreon.Routers.SearchRouter.restore()
    Coreon.Models.Session.load.restore()
    Coreon.Views.ApplicationView.restore()
    Coreon.application = null

  it 'is a Backbone model', ->
    @app.should.be.an.instanceof Backbone.Model

  describe 'defaults', ->

    it 'chooses sensible default for container selector', ->
      @app.get('el').should.equal '#coreon-app'

  describe '#initialize()', ->

    it 'makes instance globally accessible', ->
      Coreon.application.should.equal @app

    it 'enforces single instance', ->
      (-> new Coreon.Application).should.throw 'Coreon application already initialized'

    it 'configures auth root on session', ->
      Coreon.Models.Session.auth_root.should.equal 'https://auth.coreon.com'

    it 'creates application view', ->
      Coreon.Views.ApplicationView.should.have.been.calledOnce
      Coreon.Views.ApplicationView.should.have.been.calledWithNew
      Coreon.Views.ApplicationView.should.have.been.calledWith model: @app, el: '#coreon-app'

    it 'creates sessions router', ->
      Coreon.Routers.SessionsRouter.should.have.been.calledOnce
      Coreon.Routers.SessionsRouter.should.have.been.calledWithNew
      Coreon.Routers.SessionsRouter.should.have.been.calledWith @view

    it 'creates repositories router', ->
      Coreon.Routers.RepositoriesRouter.should.have.been.calledOnce
      Coreon.Routers.RepositoriesRouter.should.have.been.calledWithNew
      Coreon.Routers.RepositoriesRouter.should.have.been.calledWith @view

    it 'creates concepts router', ->
      Coreon.Routers.ConceptsRouter.should.have.been.calledOnce
      Coreon.Routers.ConceptsRouter.should.have.been.calledWithNew
      Coreon.Routers.ConceptsRouter.should.have.been.calledWith @view


  describe '#start()', ->

    it 'can be chained', ->
      @app.start().should.equal @app

    it 'throws error when no auth root was given', ->
      @app.unset 'auth_root', silent: true
      (=> @app.start() ).should.throw 'Authorization service root URL not given'

    it 'loads session', ->
      @app.start()
      Coreon.Models.Session.load.should.have.been.calledOnce

    it 'assigns session', ->
      session = new Backbone.Model
      @app.start()
      @request.resolve session
      @app.get('session').should.equal session

    it 'triggers change event for empty session', ->
      spy = sinon.spy()
      @app.on 'change:session', spy
      @app.start()
      @request.resolve null
      spy.should.have.been.calledOnce

  describe '#graphUri()', ->

    it 'returns current graph_uri', ->
      repository = new Backbone.Model graph_uri: 'https://repo123.coreon.com:4000'
      session = currentRepository: -> repository
      @app.set 'session', session, silent: yes
      @app.graphUri().should.equal 'https://repo123.coreon.com:4000'

    it 'returns null when no current repository exists', ->
      session = currentRepository: -> null
      @app.set 'session', session, silent: yes
      should.equal @app.graphUri(), null

    it 'returns null when no session exists', ->
      @app.set 'session', null, silent: yes
      should.equal @app.graphUri(), null

  describe '#repository()', ->

    it 'returns current repository from session', ->
      repo = new Backbone.Model
      session = currentRepository: -> repo
      @app.set 'session', session, silent: true
      @app.repository().should.equal repo

    it 'returns null when no session exists', ->
      @app.set 'session', null, silent: yes
      should.equal @app.repository(), null

  describe '#langs()', ->

    beforeEach ->
      @repository = usedLanguages: -> []
      @app.repository = => @repository
      @app.sourceLang = -> null
      @app.targetLang = -> null

    it 'delegates to repository', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      langs = @app.langs()
      expect( langs ).to.have.lengthOf 4
      expect( langs ).to.have.include 'en'
      expect( langs ).to.have.include 'hu'
      expect( langs ).to.have.include 'fr'
      expect( langs ).to.have.include 'de'

    it 'sorts languages alphabetically', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      langs = @app.langs()
      expect( langs ).to.eql [ 'de', 'en', 'fr', 'hu' ]

    it 'pushes source and destination langs to top', ->
      @repository.usedLanguages = -> [ 'en', 'hu', 'fr', 'de' ]
      @app.sourceLang = -> 'fr'
      @app.targetLang = -> 'en'
      langs = @app.langs()
      expect( langs ).to.eql [ 'fr', 'en', 'de', 'hu' ]

  describe '#sourceLang()', ->

    beforeEach ->
      @settings = new Backbone.Model
      @app.repositorySettings = => @settings

    it 'delegates to repository settings', ->
      @settings.set 'sourceLang', 'hu', silent: yes
      lang = @app.sourceLang()
      expect( lang ).to.equal 'hu'

    it 'defaults to null', ->
      @settings = null
      lang = @app.sourceLang()
      expect( lang ).to.be.null

  describe '#targetLang()', ->

    beforeEach ->
      @settings = new Backbone.Model
      @app.repositorySettings = => @settings

    it 'delegates to repository settings', ->
      @settings.set 'targetLang', 'hu', silent: yes
      lang = @app.targetLang()
      expect( lang ).to.equal 'hu'

    it 'defaults to null', ->
      @settings = null
      lang = @app.targetLang()
      expect( lang ).to.be.null

