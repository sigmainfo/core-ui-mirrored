#= require spec_helper
#= require modules/core_api

describe "Coreon.Modules.CoreAPI", ->

  before ->
    class Coreon.Models.CoreAPIModel extends Backbone.Model
      Coreon.Modules.include @, Coreon.Modules.CoreAPI
      urlRoot: "/concepts"

  after ->
    delete Coreon.Models.CoreAPIModel

  beforeEach ->
    @session = new Backbone.Model
    Coreon.application = new Backbone.Model session: @session 
    Coreon.application.graphUri = -> "https://repo123.coreon.com"

    @model = new Coreon.Models.CoreAPIModel

  afterEach ->
    Coreon.application = null

  describe "sync()", ->

    beforeEach ->
      @requests = []
      sinon.stub Backbone, "sync", =>
        request = $.Deferred()
        @requests.push request
        request

    afterEach ->
      Backbone.sync.restore()
      request.resolve() for request in @requests

    context "always", ->

      it "delegates to Backbone.sync", ->
        @model.sync "read", @model, username: "Nobody"
        Backbone.sync.should.have.been.calledOnce
        Backbone.sync.should.have.been.calledWith "read", @model
        Backbone.sync.firstCall.args[2].should.have.property "username", "Nobody"

      it "sends token in headers", ->
        @session.set "auth_token", "148ba2d2361930cbeef", silent: true
        @model.sync "read", @model
        Backbone.sync.firstCall.args[2].should.have.property "headers"
        Backbone.sync.firstCall.args[2].headers.should.have.property "X-Core-Session", "148ba2d2361930cbeef"

      it "generates url from repository root", ->
        Coreon.application.graphUri = -> "https://123-456-789.coreon.com"
        @model.url = -> "/concepts/1234asdfg"
        @model.sync "read", @model
        Backbone.sync.firstCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/1234asdfg"

      it "normalizes slashes when generating the url", ->
        Coreon.application.graphUri = -> "https://123-456-789.coreon.com/"
        @model.url = -> "/concepts/1234asdfg"
        @model.sync "read", @model
        Backbone.sync.firstCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/1234asdfg"

      it "triggers global request event", ->
        spy = sinon.spy()
        Coreon.Modules.CoreAPI.on "request", spy 
        @model.sync "read", @model, url: "https://foo.net/1234"
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith "read", "https://foo.net/1234", @requests[0]

      it "triggers global start event", ->
        spy = sinon.spy()
        Coreon.Modules.CoreAPI.on "start", spy 
        @model.sync "read", @model, url: "https://foo.net/1234"
        @model.sync "read", @model, url: "https://foo.net/abcd"
        spy.should.have.been.calledOnce

      it "triggers global stop event", ->
        spy = sinon.spy()
        Coreon.Modules.CoreAPI.on "stop", spy 
        @model.sync "read", @model, url: "https://foo.net/1234"
        @model.sync "read", @model, url: "https://foo.net/abcd"
        @requests[1].resolve()
        @requests[0].resolve()
        spy.should.have.been.calledOnce

    context "done", ->

      it "triggers done callbacks", ->
        done = sinon.spy()
        promise = @model.sync "create", @model
        promise.done done
        @requests[0].resolve {concept: "foo"}, "success", @requests[0]
        done.should.have.been.calledOnce
        done.should.have.been.calledOn @model
        done.should.have.been.calledWith {concept: "foo"}, @requests[0]

      it "does not trigger fail callbacks", ->
        fail = sinon.spy()
        promise = @model.sync "create", @model
        promise.fail fail
        @requests[0].resolve {concept: "foo"}, "success", @requests[0]
        fail.should.not.have.been.called

    context "fail", ->
      
      it "triggers fail callbacks", ->
        fail = sinon.spy()
        promise = @model.sync "create", @model
        promise.fail fail
        @requests[0].responseText = '{"errors":{"lang":["must be given"]}}'
        @requests[0].reject @requests[0], "error", "Unprocessible Entity"
        fail.should.have.been.calledOnce
        fail.should.have.been.calledOn @model
        fail.should.have.been.calledWith {errors: lang: ["must be given"]}, @requests[0]

      it "does not trigger done callbacks", ->
        done = sinon.spy()
        promise = @model.sync "create", @model
        promise.done done
        @requests[0].reject @requests[0], "error", "Unprocessible Entity"
        done.should.not.have.been.called

      it "fails gracefully when response text is not valid JSON", ->
        fail = sinon.spy()
        promise = @model.sync "create", @model
        promise.fail fail
        @requests[0].responseText = "Me ain't JSON!"
        @requests[0].reject @requests[0], "error", "Unprocessible Entity"
        fail.should.have.been.calledWith {}, @requests[0]

      it "triggers global error events", ->
        spy1 = sinon.spy()
        spy2 = sinon.spy()
        Coreon.Modules.CoreAPI.on "error", spy1
        Coreon.Modules.CoreAPI.on "error:422", spy2
        @model.sync "create", @model
        @requests[0].status = 422
        @requests[0].responseText = '{"error":"is not valid"}'
        @requests[0].reject @requests[0], "error", "Unprocessible Entity"
        spy1.should.have.been.calledOnce
        spy1.should.have.been.calledWith 422, "Unprocessible Entity", error: "is not valid", @requests[0]
        spy2.should.have.been.calledOnce
        spy2.should.have.been.calledWith "Unprocessible Entity", error: "is not valid", @requests[0]
    
    context "unauthorized", ->

      it "does not trigger any callbacks", ->
        done = sinon.spy()
        fail = sinon.spy()
        promise = @model.sync "create", @model
        promise.done done
        promise.fail fail
        @requests[0].status = 403
        @requests[0].reject @requests[0], "error", "Unauthorized"
        done.should.not.have.been.called
        fail.should.not.have.been.called

      it "does not trigger error event", ->
        spy = sinon.spy()
        Coreon.Modules.CoreAPI.on "error error:403", spy
        @model.sync "read", @model
        @requests[0].status = 403
        @requests[0].reject @requests[0], "error", "Unauthorized"
        spy.should.not.have.been.called

      it "does not trigger stop event", ->
        spy = sinon.spy()
        Coreon.Modules.CoreAPI.on "stop", spy
        @model.sync "read", @model
        @requests[0].status = 403
        @requests[0].reject @requests[0], "error", "Unauthorized"
        spy.should.not.have.been.called

      it "clears session token", ->
        @session.set "auth_token", "148ba2d2361930cbeef48548969b04602", silent: true
        @model.sync "read", @model
        @requests[0].status = 403
        @requests[0].reject @requests[0], "error", "Unauthorized"
        @session.has("auth_token").should.be.false
      
      it "resumes ajax request", ->
        @model.sync "read", @model, username: "Nobody"
        @requests[0].status = 403
        @requests[0].reject @requests[0], "error", "Unauthorized"
        @session.set "auth_token", "beef48548969b046148ba2d2361930c02"
        Backbone.sync.should.have.been.calledTwice
        Backbone.sync.should.always.have.been.calledWith "read", @model
        Backbone.sync.lastCall.args[2].should.have.property "username", "Nobody"

      it "uses newly set token", ->
        @session.set "auth_token", "148ba2d2361930cbeef48548969b04602", silent: true
        @model.sync "read", @model
        @requests[0].status = 403
        @requests[0].reject @requests[0], "error", "Unauthorized"
        Backbone.sync.reset()
        @session.set "auth_token", "beef48548969b046148ba2d2361930c02"
        Backbone.sync.firstCall.args[2].should.have.property "headers"
        Backbone.sync.firstCall.args[2].headers.should.have.property "X-Core-Session", "beef48548969b046148ba2d2361930c02"
    
    context "batch requests", ->

      beforeEach ->
        @clock = sinon.useFakeTimers()

      afterEach ->
        Coreon.Modules.CoreAPI.sync "abort"
        @clock.restore()

      it "triggers first request normally", ->
        Coreon.application.graphUri = -> "https://repo123.coreon.com"
        @model.id = "123"
        @model.sync "read", @model, batch: on
        @model.sync "read", @model, batch: on
        Backbone.sync.should.have.been.calledOnce
        Backbone.sync.should.have.been.calledWith "read", @model
        options = Backbone.sync.firstCall.args[2]
        options.should.have.property "url", "https://repo123.coreon.com/concepts/123"
        options.should.have.property "batch", on

      it "collects subsequent requests in a single batch request", ->
        for i in [1..5]
          @model.sync "read", @model, batch: on
        @clock.tick 300
        Backbone.sync.should.have.been.calledTwice
        Backbone.sync.should.always.have.been.calledWith "read"
        options = Backbone.sync.secondCall.args[2]
        options.should.have.property "type", "POST"

      it "batches request only for read requests", ->
        @model.sync "update", @model, batch: on
        @model.sync "update", @model, batch: on
        Backbone.sync.should.have.been.calledTwice

      it "generates url and data from model", ->
        Coreon.application.graphUri = -> "https://123-456-789.coreon.com/"
        @model.urlRoot = "concepts"
        for i in [1..5]
          @model.id = i
          @model.sync "read", @model, batch: on
        @clock.tick 300
        options = Backbone.sync.secondCall.args[2]
        options.should.have.property "url", "https://123-456-789.coreon.com/concepts/fetch"
        options.should.have.deep.property("data.ids").that.eqls [2, 3, 4, 5]

      it "creates one batch per url", ->
        for i in [1..3]
          @model.urlRoot = "concepts"
          @model.sync "read", @model, batch: on
        for i in [1..3]
          @model.urlRoot = "models"
          @model.sync "read", @model, batch: on
        for i in [1..3]
          @model.sync "read", @model, batch: on, url: "http://foo"
        Backbone.sync.reset()
        @clock.tick 300
        Backbone.sync.should.have.been.calledThrice

      it "does not create empty batch request", ->
        @model.sync "read", @model, batch: on
        Backbone.sync.reset()
        @clock.tick 300
        Backbone.sync.should.not.have.been.called

      it "resolves promise for every request individually", ->
        promises = []
        for i in [1..3]
          @model.urlRoot = "concepts"
          promises.push @model.sync "read", @model, batch: on
        @clock.tick 300
        @requests[1].resolve()
        promises[1].should.not.equal promises[2]
        promises[1].state().should.equal "resolved"
        promises[2].state().should.equal "resolved"

      xit "rejects  promise for every request individually"

      xit "triggers events for every model individually"

      xit "clears pending batches when aborted", ->
        @model.sync "read", @model, batch: on
        for i in [1..5]
          model = new Coreon.Models.CoreAPIModel _id: i
          model.sync "read", model, batch: on
        @model.sync "abort"
        Backbone.sync.reset()
        @clock.tick 300
        @model.sync "read", @model, batch: on
        Backbone.sync.should.have.been.calledOnce

