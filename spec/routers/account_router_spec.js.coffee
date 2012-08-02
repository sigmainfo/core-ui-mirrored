#= require spec_helper
#= require routers/account_router

describe "Coreon.Routers.AccountRouter", ->
  
  beforeEach ->
    @router = new Coreon.Routers.AccountRouter
    console.log Coreon

  it "is a Backbone router", ->
    console.log @router
    @router.should.be.an.instanceOf Backbone.Router

  context "#logout", ->

    it "is properly routed", ->
      @router.routes["account/logout"].should.equal "logout"
