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

  context "#logout", ->

    it "delegates logout to CoreClient", ->
      sinon.spy CoreClient.Auth, "authenticate"
      @account.logout()
      CoreClient.Auth.authenticate.should.have.been.calledWith false
      CoreClient.Auth.authenticate.restore()

    it "resets userName", ->
      @account.set "userName", "Nobody", silent: true 
      @account.logout()
      expect(@account.get "userName").to.be.undefined

    it "triggers event", ->
      spy = sinon.spy()
      @account.on "logout", spy
      @account.logout()
      spy.should.have.been.calledOnce

  context "#login", ->

    beforeEach ->
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()

    it "delegates login to CoreClient", ->
      sinon.spy CoreClient.Auth, "authenticate"
      @account.login "nobody", "se7en"
      CoreClient.Auth.authenticate.should.have.been.calledWith "nobody", "se7en"
      CoreClient.Auth.authenticate.restore()

    context "on success", ->
      
      beforeEach ->
        @server.respondWith [201, {"Content-Type": "application/json"}, "{}"]
        sinon.stub CoreClient.Auth, "getUserName" , -> "Wiliam Blake"

      afterEach ->
        CoreClient.Auth.getUserName.restore()

      it "triggers event", ->
        spy = sinon.spy()
        @account.on "login", spy
        @account.login "nobody", "seven"
        @server.respond()
        spy.should.have.been.calledOnce

      it "sets user name", ->
        @account.login "nobody", "seven"
        @server.respond()
        @account.get("userName").should.equal "Wiliam Blake"
