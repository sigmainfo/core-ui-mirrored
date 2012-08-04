#= require spec_helper
#= require routers/account_router

describe "Coreon.Routers.AccountRouter", ->
  
  beforeEach ->
    @router = new Coreon.Routers.AccountRouter

  it "is a Backbone router", ->
    @router.should.be.an.instanceOf Backbone.Router

  context "#logout", ->

    it "is properly routed", ->
      @router.routes["account/logout"].should.equal "logout"

    it "kills session", ->
      sinon.spy CoreClient.Auth, "authenticate"
      @router.logout()
      CoreClient.Auth.authenticate.should.have.been.calledWith false
      CoreClient.Auth.authenticate.restore()

    it "redirects to login", ->
      sinon.spy @router, "navigate"
      @router.logout()
      @router.navigate.should.have.been.calledWith "account/login", trigger: true
