#= require spec_helper
#= require routers/sessions_router

describe 'Coreon.Routers.SessionsRouter', ->

  app = null
  router = null

  beforeEach ->
    app = new Backbone.Model
    router = new Coreon.Routers.SessionsRouter app
    Backbone.history.start()

  afterEach ->
    Backbone.history.stop()

  it 'is a Backbone router', ->
    expect(router).to.be.an.instanceof Backbone.Router

  describe '#destroy()', ->

    it 'is routed', ->
      destroy = sinon.spy()
      router.destroy = destroy
      router._bindRoutes()
      router.navigate 'logout', trigger: yes
      expect(destroy).to.have.been.calledOnce

    it 'clears notifications', ->
      reset = sinon.spy()
      Coreon.Models.Notification.collection = ->
        reset: reset
      router.destroy()
      expect(reset).to.have.been.calledOnce
      expect(reset).to.have.been.calledWith []

    context 'with session', ->

      request = null
      session = null

      beforeEach ->
        request = $.Deferred()
        session = destroy: sinon.spy -> request.promise()
        app.set 'session', session, silent: yes

      it 'destroys session', ->
        destroy = session.destroy
        router.destroy()
        expect(destroy).to.have.been.calledOnce
        current = app.get('session')
        expect(current).to.be.null

      it 'defers navigate', ->
        navigate = sinon.spy()
        router.navigate = navigate
        router.destroy()
        expect(navigate).to.not.have.been.called

      it 'navigates to root when defered request is resolved', ->
        navigate = sinon.spy()
        router.navigate = navigate
        router.destroy()
        request.resolve()
        expect(navigate).to.have.been.calledOnce
        expect(navigate).to.have.been.calledWith '', reload: yes

      it 'navigates to root when defered request is rejected', ->
        navigate = sinon.spy()
        router.navigate = navigate
        router.destroy()
        request.reject()
        expect(navigate).to.have.been.calledOnce
        expect(navigate).to.have.been.calledWith '', reload: yes

    context 'without session', ->

      beforeEach ->
        app.set 'session', null, silent: yes

      it 'navigates to root', ->
        navigate = sinon.spy()
        router.navigate = navigate
        router.destroy()
        expect(navigate).to.have.been.calledOnce
        expect(navigate).to.have.been.calledWith '', reload: yes
