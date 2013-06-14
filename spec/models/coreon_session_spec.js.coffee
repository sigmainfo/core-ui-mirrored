#= require spec_helper
#= require models/coreon_session
#= require modules/core_api

describe "Coreon.Models.CoreonSession", ->

  beforeEach ->
    @session = new Coreon.Models.CoreonSession

  afterEach ->
    localStorage.clear()
    @session.destroy()

  it "is a Backbone model", ->
    @session.should.be.an.instanceof Backbone.Model

  describe "with defaults", ->

    it "is inactive", ->
      @session.valid().should.be.false

    it "has no user name", ->
      @session.get("user_name").should.be.false

    it "has no emails", ->
      @session.get("emails").should.be.an.instanceof(Array).with.lengthOf 0

    it "has api paths set on domain", ->
      @session.get("auth_root").should.equal "/api/auth/"

    it "selects no repository by default", ->
      @session.get("repo_root").should.be.false


  describe "initialize()", ->

    it "creates ability", ->
      should.exist @session.ability
      @session.ability.should.be.an.instanceof Coreon.Models.Ability

    it "depricates use of connections", ->
      should.not.exist @session.connections

    it "creates notifications", ->
      @session.notifications.should.be.an.instanceof Coreon.Collections.Notifications


  describe "activate()", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      I18n.t.restore()
      @xhr.restore()

    it "sets email on model", ->
      @session.activate("rick.deckard@tyrell.tld", "obsolescence")
      @request.respond 200, {"Content-Type": "application/json"}, JSON.stringify(@session_factory())
      @session.get("emails").should.contain "rick.deckard@tyrell.tld"

    it "calls auth service with credentials", ->
      @session.set "auth_root", "https://api.coreon.com/auth/"
      @session.activate("rick.deckard@tyrell.tld", "obsolescence")
      @request.url.should.equal "https://api.coreon.com/auth/login"
      @request.method.should.equal "POST"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "email=rick.deckard%40tyrell.tld&password=obsolescence"

    it "triggers callback on success", ->
      @session.onFetch = sinon.spy()
      @session.activate("rick.deckard@tyrell.tld", "obsolescence")
      @request.respond 200, {"Content-Type": "application/json"}, '{"message": "Logged in"}'
      @session.onFetch.should.have.been.calledOnce

    it "triggers event on activation", ->
      spy = sinon.spy()
      @session.on "change:token", spy
      @session.activate("rick.deckard@tyrell.tld", "obsolescence")
      @request.respond 200, {"Content-Type": "application/json"}, '{"message": "Logged in"}'
      spy.should.have.been.calledOnce


  describe "onFetch()", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @data = @session_factory()

    afterEach ->
      I18n.t.restore()

    it "sets a token", ->
      @session.setToken = sinon.spy()
      @session.onFetch @data
      @session.setToken.should.be.calledOnce

    it "sets the right token", ->
      @session.onFetch @data
      localStorage.session.should.equal @data.auth_token

     it "becomes a valid session", ->
      @session.onFetch @data
      @session.valid().should.be.true

    it "stores user name and email", ->
      @session.onFetch @data
      @session.get("user_name").should.equal @data.user.name
      @session.get("user_id").should.equal @data.user.id
      @session.get("emails").should.equal @data.user.emails

    it "triggers event on fetch", ->
      spy = sinon.spy()
      @session.on "change:token", spy
      @session.onFetch @data
      spy.should.have.been.calledOnce

    it "sends notification on activation", ->
      @session.message = sinon.spy()
      I18n.t.withArgs("notifications.account.login").returns "Logged in"
      @session.onFetch @data
      @session.message.should.have.been.calledWith "Logged in"

    it "selects first repository automatically", ->
      @session.setRepository = sinon.stub()
      @session.onFetch @data
      @session.setRepository.should.have.been.calledWith @data.repositories[0]


  describe "reactivate()", ->

    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "calls auth service with credentials", ->
      @session.set
        auth_root: "https://api.coreon.com/auth/"
        user_id: "someFancyUserId"
      @session.reactivate "obsolescence"
      @request.url.should.equal "https://api.coreon.com/auth/login"
      @request.method.should.equal "POST"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "user_id=someFancyUserId&password=obsolescence"

    it "triggers event on reactivation", ->
      spy = sinon.spy()
      @session.on "change:token", spy
      @session.reactivate "obsolescence"
      @request.respond 200, {"Content-Type": "application/json"}, '{"message": "Logged in"}'
      spy.should.have.been.calledOnce


  describe "deactivate()", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @session.setToken("fancyToken-xyz")

    afterEach ->
      I18n.t.restore()

    it "adjusts state", ->
      @session.deactivate()
      @session.valid().should.be.false

    it "resets name", ->
      @session.deactivate()
      @session.get("user_name").should.be.false

    it "resets session", ->
      @session.deactivate()
      should.not.exist localStorage.getItem "session"

    it "triggers event on deactivation", ->
      spy = sinon.spy()
      @session.on "change:token", spy
      @session.deactivate()
      spy.should.have.been.calledOnce

    it "sends notification on deactivation", ->
      @session.message = sinon.spy()
      I18n.t.withArgs("notifications.account.logout").returns "Logged out"
      @session.deactivate()
      @session.message.should.have.been.calledWith "Logged out"


  describe "sync()", ->

    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()


    it "fetches data via login on create", ->
      @session.set "auth_root", "/api/auth/"
      @session.sync "create", @session, {email:"rick.deckard@tyrell.tld", password:"obsolescence"}
      @request.method.should.equal "POST"
      @request.url.should.equal "/api/auth/login"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "email=rick.deckard%40tyrell.tld&password=obsolescence"


    it "fetches data via user_id on update", ->
      @session.set "auth_root", "/api/auth/"
      @session.set "user_id", "coffeebabe23coffeebabe42"
      @session.sync "update", @session, password:"obsolescence"
      @request.method.should.equal "POST"
      @request.url.should.equal "/api/auth/login"
      @request.requestHeaders["Accept"].should.contain "application/json"
      @request.requestBody.should.equal "user_id=coffeebabe23coffeebabe42&password=obsolescence"


    it "fetches data via token on read", ->
      @session.set "auth_root", "/api/auth/"
      @session.getToken = -> "fancySessionToken"
      @session.sync "read", @session
      @request.method.should.equal "GET"
      @request.url.should.equal "/api/auth/login/fancySessionToken"


    it "gives server notice of departure on destroy", ->
      @session.isNew = -> false
      @session.set "auth_root", "/api/auth/"
      @session.getToken = -> "fancySessionToken"
      @session.destroy()
      @request.method.should.equal "DELETE"
      @request.url.should.equal "/api/auth/login/fancySessionToken"


    it "unsets token on destroy", ->
      @session.isNew = -> false
      @session.unsetToken = sinon.spy()
      @session.destroy()
      @session.unsetToken.should.be.calledOnce


    it "resets name and session on destroy", ->
      @session.isNew = -> false
      @session.set "user_name", "Rick Deckard"
      @session.destroy()
      should.not.exist localStorage.getItem "session"
      @session.get("user_name").should.be.false


    it "clears storage", ->
      @session.isNew = -> false
      @session.setToken "fancySessionToken"
      @session.destroy()
      should.not.exist localStorage.getItem "session"


    it "doesn't try to fetch without a token", ->
      $.ajax = sinon.stub()
      @session.set "auth_root", "/api/auth/"
      @session.getToken = -> null
      @session.sync "read", @session
      $.ajax.should.not.have.been.called
      $.ajax.reset()


  describe "setRepository()", ->
    beforeEach ->
      @session.ability = set: sinon.stub()

    it "sets reporitory root", ->
      @session.setRepository
        graph_uri: "/graph/uri"
        user_roles: []
      @session.get("repo_root").should.equal "/graph/uri"

    it "selects highest user role", ->
      @session.setRepository
        graph_uri: "/graph/uri"
        user_roles: ["user"]
      @session.ability.set.should.be.calledWith "role", "user"

    it "doesn't crash if user_roles in null", ->
      @session.setRepository
        graph_uri: "/graph/uri"
        user_roles: null
      @session.ability.set.should.be.calledWith "role", false

    it "selects highest user role", ->
      @session.setRepository
        graph_uri: "/graph/uri"
        user_roles: []
      @session.ability.set.should.be.calledWith "role", false

      @session.setRepository
        graph_uri: "/graph/uri"
        user_roles: ["user"]
      @session.ability.set.should.be.calledWith "role", "user"

      @session.setRepository
        graph_uri: "/graph/uri"
        user_roles: ["user", "maintainer"]
      @session.ability.set.should.be.calledWith "role", "maintainer"

