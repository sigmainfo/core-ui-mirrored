#= require spec_helper
#= require routers/account_router

describe "Coreon.Routers.AccountRouter", ->
  
  beforeEach ->
    @router = new Coreon.Routers.AccountRouter

  it "is a Backbone router", ->
    @router.should.be.an.instanceOf Backbone.Router
