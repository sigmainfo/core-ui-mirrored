#= require spec_helper
#= require models/account

describe "Coreon.Models.Account", ->
    
  beforeEach ->
    @account = new Coreon.Models.Account

  it "is a Backbone model", ->
    @account.should.be.an.instanceof Backbone.Model

  context "#idle", ->

    it "determines status from CoreClient", ->
      stub = sinon.stub CoreClient.Auth, "isAuthenticated"
      stub.returns true
      @account.idle().should.be.false
      stub.returns false
      @account.idle().should.be.true
      stub.restore()
