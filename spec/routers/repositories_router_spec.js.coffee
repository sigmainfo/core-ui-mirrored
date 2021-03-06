#= require spec_helper
#= require routers/repositories_router

describe 'Coreon.Routers.RepositoriesRouter', ->

  app = null
  router = null
  session = null

  beforeEach ->
    app = new Backbone.Model
    session = new Backbone.Model
    app.set 'session', session, silent: yes
    router = new Coreon.Routers.RepositoriesRouter app

  it 'is a Backbone router', ->
    expect(router).to.be.an.instanceOf Backbone.Router

  describe '#_bindRoutes()', ->

    beforeEach ->
      Backbone.history.start silent: yes
      router.navigate 'previous/path'

    afterEach ->
      Backbone.history.stop()

    it 'routes root to index', ->
      index = sinon.spy()
      router.index = index
      router._bindRoutes()
      router.navigate '', trigger: yes
      expect(index).to.have.been.calledOnce

    it 'routes id to show', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      router.navigate '5272466670686f14a0030000', trigger: yes
      expect(show).to.have.been.calledOnce
      expect(show).to.have.been.calledWith '5272466670686f14a0030000'

    it 'does not route invalid ids', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      router.navigate '123', trigger: yes
      expect(show).to.not.have.been.called

    it 'allows trailing slash in route', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      router.navigate '5272466670686f14a0030000/', trigger: yes
      expect(show).to.have.been.calledOnce
      expect(show).to.have.been.calledWith '5272466670686f14a0030000'

    it 'allows concepts path in route', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      router.navigate '5272466670686f14a0030000/concepts', trigger: yes
      expect(show).to.have.been.calledOnce
      expect(show).to.have.been.calledWith '5272466670686f14a0030000'

    it 'allows trailing slash with concepts path in route', ->
      show = sinon.spy()
      router.show = show
      router._bindRoutes()
      router.navigate '5272466670686f14a0030000/concepts/', trigger: yes
      expect(show).to.have.been.calledOnce
      expect(show).to.have.been.calledWith '5272466670686f14a0030000'

  describe '#index()', ->

    navigate = null

    beforeEach ->
      navigate = sinon.spy()
      router.navigate = navigate
      sinon.stub localStorage, 'getItem'

    afterEach ->
      localStorage.getItem.restore()

    it 'redirects to client stored repository', ->
      session.set 'repositories', [{id: 'my-repo-123'}, {id: 'my-other-repo-456'}], silent: yes
      session.repositoryByCacheId = -> {id: 'my-other-repo-456'}
      localStorage.getItem.returns 'some-cache-id'
      router.index()
      expect(navigate).to.have.been.calledOnce
      expect(navigate).to.have.been.calledWith 'my-other-repo-456'
                                             , trigger: yes
                                             , replace: yes

    it 'redirects to first repository', ->
      session.set 'repositories', [{id: 'my-repo-123'}, {id: 'my-other-repo-456'}], silent: yes
      localStorage.getItem.returns null
      router.index()
      expect(navigate).to.have.been.calledOnce
      expect(navigate).to.have.been.calledWith 'my-repo-123'
                                             , trigger: yes
                                             , replace: yes

    it 'kills session when there is no repository available', ->
      session.set 'repositories', [], silent: yes
      session.repositoryByCacheId = -> null
      router.index()
      expect(navigate).to.have.been.calledOnce
      expect(navigate).to.have.been.calledWith 'logout'

  describe '#show()', ->

    repository = null
    select = null

    beforeEach ->
      select = sinon.spy()
      app.selectRepository = select
      repository = new Backbone.Model

    it 'switches to given repository', ->
      router.show '50990fb960303934ea000041'
      expect(select).to.have.been.calledOnce
      expect(select).to.have.been.calledWith '50990fb960303934ea000041'

    it 'clears selection', ->
      app.set 'selection', new Backbone.Collection, silent: yes
      router.show '50990fb960303934ea000041'
      selection = app.get('selection')
      expect(selection).to.be.null
