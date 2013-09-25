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

    @requests = []
    sinon.stub Backbone, "sync", (method, model, options) =>
      request = $.Deferred()
      request.status = 200
      request.abort = -> @reject()
      model.trigger "request", model, request, options
      @requests.push request
      request

    @model = new Coreon.Models.CoreAPIModel

  afterEach ->
    @model.sync "abort"
    Backbone.sync.restore()
    Coreon.application = null

  describe "sync()", ->

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

      it "allows changing the default for wait option", ->
        @model.sync "read", @model, wait: no
        Backbone.sync.firstCall.args[2].should.have.property "wait", no

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

      it "triggers first request immediately", ->
        Coreon.application.graphUri = -> "https://repo123.coreon.com"
        @model.id = "123"
        @model.sync "read", @model, batch: on
        @model.id = "456"
        @model.sync "read", @model, batch: on
        Backbone.sync.should.have.been.calledOnce
        Backbone.sync.should.have.been.calledWith "read", @model
        options = Backbone.sync.firstCall.args[2]
        options.should.have.property "url", "https://repo123.coreon.com/concepts/123"
        options.should.have.property "batch", on

      it "collects subsequent requests in a single batch request", ->
        for i in [1..5]
          @model.id = "model-#{i}"
          @model.sync "read", @model, batch: on
        @requests[0].resolve()
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
          model = new Coreon.Models.CoreAPIModel
          model.id = "m#{i}"
          model.sync "read", model, batch: on
        @requests[0].resolve()
        options = Backbone.sync.secondCall.args[2]
        options.should.have.property "url", "https://123-456-789.coreon.com/concepts/fetch"
        options.should.have.deep.property("data.ids").that.eqls ["m2", "m3", "m4", "m5"]

      it "allows overriding url in options", ->
        for i in [1..5]
          model = new Coreon.Models.CoreAPIModel
          model.sync "read", model, batch: on, url: "https://cummon.let.se/fetch"
        @requests[0].resolve()
        options = Backbone.sync.secondCall.args[2]
        options.should.have.property "url", "https://cummon.let.se/fetch"

      it "operates on a copy of the options hash", ->
        @model.on "request", (model, request, options) -> options.xhr = readyStste: 4
        @model.sync "read", @model, batch: on
        for i in [1..3]
          model = new Coreon.Models.CoreAPIModel
          model.sync "read", model, batch: on
        @requests[0].resolve()
        Backbone.sync.secondCall.args[2].should.not.have.property "xhr"

      it "does not create empty batch request", ->
        @model.sync "read", @model, batch: on
        Backbone.sync.reset()
        @requests[0].resolve()
        Backbone.sync.should.not.have.been.called

      it "creates one batch per url", ->
        for i in [1..3]
          @model.urlRoot = "concepts"
          @model.sync "read", @model, batch: on
        for i in [1..3]
          @model.urlRoot = "terms"
          @model.sync "read", @model, batch: on
        for i in [1..3]
          model = new Coreon.Models.CoreAPIModel
          model.id = "m-#{i}"
          model.sync "read", model, batch: on, url: "http://foo"
        Backbone.sync.should.have.been.calledThrice
        Backbone.sync.reset()
        request.resolve() for request in @requests
        Backbone.sync.should.have.been.calledThrice
        Backbone.sync.thirdCall.args[2].should.have.deep.property("data.ids").that.eqls ["m-2", "m-3"]

      it "limits size of batch request", ->
        for i in [1..10]
          model = new Coreon.Models.CoreAPIModel
          model.id = "m-#{i}"
          model.sync "read", model, batch: on, batch_limit: 5
        @requests[0].resolve()
        Backbone.sync.secondCall.args[2].should.have.deep.property("data.ids").with.lengthOf 5

      it "keeps fetching batches until done", ->
        for i in [1..10]
          model = new Coreon.Models.CoreAPIModel
          model.id = "m-#{i}"
          model.sync "read", model, batch: on, batch_limit: 5
        @requests[0].resolve()
        @requests[1].resolve()
        @requests[2].resolve()
        Backbone.sync.should.have.been.calledThrice
        Backbone.sync.thirdCall.args[2].should.have.deep.property("data.ids").that.eqls [ "m-7", "m-8", "m-9", "m-10" ]

      it "triggers request events", ->
        Coreon.application.graphUri = -> "https://123-456-789.coreon.com/"
        spy = sinon.spy()
        promises = []
        models = []
        for i in [1..3]
          model = new Coreon.Models.CoreAPIModel
          model.id = "model_#{i}"
          model.on "request", spy
          promises.push model.sync "read", model, batch: on
          models.push model
        @requests[0].resolve()

        spy.should.have.been.calledThrice

        spy.firstCall.should.have.been.calledWith models[0], @requests[0]
        spy.firstCall.args[2].should.have.property "batch", on
        spy.firstCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/model_1"

        spy.secondCall.should.have.been.calledWith models[1], @requests[1]
        spy.secondCall.args[2].should.have.property "batch", on
        spy.secondCall.args[2].should.have.property "type", "POST"
        spy.secondCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/fetch"

        spy.thirdCall.should.have.been.calledWith models[2], @requests[1]
        spy.thirdCall.args[2].should.have.property "batch", on
        spy.thirdCall.args[2].should.have.property "type", "POST"
        spy.thirdCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/fetch"

      context "done", ->
        
        it "resolves each promise individually", ->
          promises = []
          models = []
          spy = sinon.spy()
          for i in [1..3]
            model = new Coreon.Models.CoreAPIModel
            model.id = "m-#{i}"
            promises.push model.sync "read", model, batch: on
            models.push model
          promise.done spy for promise in promises

          @requests[0].resolve {id: "m-1"}, "success", @requests[0]
          spy.should.have.been.calledOnce

          spy.should.have.been.calledOn models[0]
          spy.should.have.been.calledWith {id: "m-1"}, @requests[0]

          @requests[1].resolve [{id: "m-2"}, {id: "m-3"}], "success", @requests[1]
          spy.should.have.been.calledThrice

          spy.secondCall.should.have.been.calledOn models[1]
          spy.secondCall.should.have.been.calledWith {id: "m-2"}, @requests[1]

          spy.thirdCall.should.have.been.calledOn models[2]
          spy.thirdCall.should.have.been.calledWith {id: "m-3"}, @requests[1]

        it "triggers success callbacks individually", ->
          models = []
          spies = []
          for i in [1..3]
            model = new Coreon.Models.CoreAPIModel
            model.id = "m-#{i}"
            models.push model
            spy = sinon.spy()
            spies.push spy
            model.sync "read", model, batch: on, success: spy
          @requests[0].resolve {id: "m-1"}, "success", @requests[0]
          @requests[1].resolve [{id: "m-2"}, {id: "m-3"}], "success", @requests[1]

          Backbone.sync.firstCall.args[2].should.have.property "success", spies[0]

          spies[1].should.have.been.calledOnce
          spies[1].should.have.been.calledWith {id: "m-2"}, "success", @requests[1]

          spies[2].should.have.been.calledOnce
          spies[2].should.have.been.calledWith {id: "m-3"}, "success", @requests[1]

      context "fail", ->

        it "rejects each promise individually", ->
          promises = []
          models = []
          spy = sinon.spy()
          for i in [1..3]
            model = new Coreon.Models.CoreAPIModel
            model.id = "m-#{i}"
            promises.push model.sync "read", model, batch: on
            models.push model
          promise.fail spy for promise in promises
          
          @requests[0].status = 404
          @requests[0].responseText = '{"message":"Whahappan?"}'
          @requests[0].reject @requests[0], "error", "Not Found"
          spy.should.have.been.calledOnce

          spy.should.have.been.calledOn models[0]
          spy.should.have.been.calledWith {message: "Whahappan?"}, @requests[0]

          @requests[1].status = 404
          @requests[1].responseText = '{"message":"Whahappan again?"}'
          @requests[1].reject @requests[1], "error", "Not Found"
          spy.should.have.been.calledThrice

          spy.secondCall.should.have.been.calledOn models[1]
          spy.secondCall.should.have.been.calledWith {message: "Whahappan again?"}, @requests[1]

          spy.thirdCall.should.have.been.calledOn models[2]
          spy.thirdCall.should.have.been.calledWith {message: "Whahappan again?"}, @requests[1]

        it "triggers error callbacks individually", ->
          models = []
          spies = []
          for i in [1..3]
            model = new Coreon.Models.CoreAPIModel
            model.id = "m-#{i}"
            models.push model
            spy = sinon.spy()
            spies.push spy
            model.sync "read", model, batch: on, error: spy

          @requests[0].resolve {id: "m-1"}, "success", @requests[0]
          @requests[1].status = 404
          @requests[1].statusText = "Not Found"
          @requests[1].reject @requests[1], "error", "Not Found"

          Backbone.sync.firstCall.args[2].should.have.property "error", spies[0]

          spies[1].should.have.been.calledOnce
          spies[1].should.have.been.calledWith @requests[1], "error", "Not Found"

          spies[2].should.have.been.calledOnce
          spies[2].should.have.been.calledWith @requests[1], "error", "Not Found"

    context "abort", ->
      
      it "cancels pending requests", ->
        connections = (@model.sync "read", @model for i in [1..5])
        @model.sync "abort"
        for connection in connections
          connection.state().should.equal "rejected"
