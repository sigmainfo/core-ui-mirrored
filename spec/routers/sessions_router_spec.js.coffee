#= require spec_helper
#= require routers/sessions_router

describe "Coreon.Routers.SessionsRouter", ->

  beforeEach ->
    @application = new Backbone.Model
    view = new Backbone.View model: @application
    @router = new Coreon.Routers.SessionsRouter view
    Backbone.history.start()

  afterEach ->
    Backbone.history.stop()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "destroy()", ->

    it "clears notifications", ->
      Coreon.Models.Notification.collection = =>
        @reset_notifiations = sinon.stub()
        reset: @reset_notifiations
      @router.destroy()
      @reset_notifiations.should.have.been.calledOnce
      @reset_notifiations.should.have.been.calledWith []


    it "is routed", ->
      @router.destroy = sinon.spy()
      @router._bindRoutes()
      @router.navigate "logout", trigger: on
      @router.destroy.should.have.been.calledOnce

    it "destroys session", ->
      session =
        destroy: sinon.spy -> abort: ->
      @application.set "session", session, silent: on
      @router.destroy()
      session.destroy.should.have.been.calledOnce
      session.destroy.should.have.been.calledWith abort: yes
      should.equal @application.has("session"), no

    it "navigates to root", ->
      @router.navigate = sinon.spy()
      @router.destroy()
      @router.navigate.should.have.been.calledOnce
