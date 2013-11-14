#= require spec_helper
#= require routers/sessions_router

describe 'Coreon.Routers.SessionsRouter', ->

  beforeEach ->
    @application = new Backbone.Model
    view = new Backbone.View model: @application
    @router = new Coreon.Routers.SessionsRouter view
    Backbone.history.start()

  afterEach ->
    Backbone.history.stop()

  it 'is a Backbone router', ->
    expect( @router ).to.be.an.instanceof Backbone.Router

  describe 'destroy()', ->

    it 'clears notifications', ->
      Coreon.Models.Notification.collection = =>
        @reset_notifiations = sinon.stub()
        reset: @reset_notifiations
      @router.destroy()
      expect( @reset_notifiations ).to.have.been.calledOnce
      expect( @reset_notifiations ).to.have.been.calledWith []


    it 'is routed', ->
      @router.destroy = sinon.spy()
      @router._bindRoutes()
      @router.navigate 'logout', trigger: on
      expect( @router.destroy ).to.have.been.calledOnce
      
    context 'with session', ->
      
      beforeEach ->
        @request = $.Deferred()
        @session =
          destroy: sinon.spy => @request.promise()
        @application.set 'session', @session, silent: on
        
      
      it 'destroys session', ->
        @router.destroy()
        expect( @session.destroy ).to.have.been.calledOnce
        should.equal @application.has('session'), no
      
      it 'defers navigate', ->
        @router.navigate = sinon.spy()
        @router.destroy()
        expect( @router.navigate ).to.not.have.been.called     
      
      it 'navigates to root when defered request is resolved', ->
        @router.navigate = sinon.spy()
        @router.destroy()
        @request.resolve()
        expect( @router.navigate ).to.have.been.calledOnce

      it 'navigates to root when defered request is rejected', ->
        @router.navigate = sinon.spy()
        @router.destroy()
        @request.reject()
        expect( @router.navigate ).to.have.been.calledOnce
 
    context 'without session', ->
      
      beforeEach ->
        @application.set 'session', undefined, silent: on
      
      it 'navigates to root', ->
        @router.navigate = sinon.spy()
        @router.destroy()
        expect( @router.navigate ).to.have.been.calledOnce
