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

    it "is routed", ->
      @router.destroy = sinon.spy()
      @router._bindRoutes()
      @router.navigate "logout", trigger: on
      @router.destroy.should.have.been.calledOnce

    it "destroys session", ->
      session = destroy: sinon.spy()
      @application.set "session", session, silent: on
      @router.destroy()
      session.destroy.should.have.been.calledOnce
      should.equal @application.has("session"), false

    it "navigates to root", ->
      @router.navigate = sinon.spy()
      @router.destroy()
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "/", reload: on
