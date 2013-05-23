#= require spec_helper
#= require modules/helpers
#= require modules/core_api
# 
describe "Coreon.Modules.CoreAPI", ->

  before ->
    class Coreon.Models.CoreAPIModel extends Backbone.Model
      Coreon.Modules.include @, Coreon.Modules.CoreAPI

  after ->
    delete Coreon.Models.CoreAPIModel

  beforeEach ->
    @_application = Coreon.application
    Coreon.application =
      session: new Backbone.Model
        repository_root: "https://1234-345.coreon.com"
    @model = new Coreon.Models.CoreAPIModel
    @model.urlRoot = "/concepts"

  afterEach ->
    Coreon.application = @_application

  describe "sync()", ->

    beforeEach ->
      @xhr =
        done: ->
        fail: ->
      sinon.stub Backbone, "sync", => @xhr

    afterEach ->
      Backbone.sync.restore()

    it "delegates to Backbone.sync", ->
      @model.sync "read", @model, username: "Nobody"
      Backbone.sync.should.have.been.calledOnce
      Backbone.sync.should.have.been.calledWith "read", @model
      Backbone.sync.firstCall.args[2].should.have.property "username", "Nobody"

    it "sends token in headers", ->
      Coreon.application.session.set "token", "148ba2d2361930cbeef"
      @model.sync "read", @model
      Backbone.sync.firstCall.args[2].should.have.property "headers"
      Backbone.sync.firstCall.args[2].headers.should.have.property "X-Core-Session", "148ba2d2361930cbeef"

    it "generates url from repository root", ->
      Coreon.application.session.set "repository_root", "https://123-456-789.coreon.com"
      @model.url = -> "/concepts/1234asdfg"
      @model.sync "read", @model
      Backbone.sync.firstCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/1234asdfg"

    it "normalizes slashes when generating the url", ->
      Coreon.application.session.set "repository_root", "https://123-456-789.coreon.com/"
      @model.url = -> "/concepts/1234asdfg"
      @model.sync "read", @model
      Backbone.sync.firstCall.args[2].should.have.property "url", "https://123-456-789.coreon.com/concepts/1234asdfg"

    context "with valid session", ->

      context "done", ->

        beforeEach ->
          callbacks = []
          @xhr.done = (callback) ->
            callbacks.push callback
          @respond = (data, status, xhr) ->
            callback.apply xhr, arguments for callback in callbacks

        it "triggers done callbacks", ->
          done = sinon.spy()
          promise = @model.sync "create", @model
          promise.done done
          @respond {concept: "foo"}, "success", @xhr
          done.should.have.been.calledOnce
          done.should.have.been.calledOn @model
          done.should.have.been.calledWith {concept: "foo"}, @xhr

        it "does not trigger fail callbacks", ->
          fail = sinon.spy()
          promise = @model.sync "create", @model
          promise.fail fail
          @respond {concept: "foo"}, "success", @xhr
          fail.should.not.have.been.called

      context "fail", ->
        
        beforeEach ->
          callbacks = []
          @xhr.fail = (callback) ->
            callbacks.push callback
          @respond = (xhr, status, error) ->
            callback.apply xhr, arguments for callback in callbacks

        it "triggers fail callbacks", ->
          fail = sinon.spy()
          @xhr.responseText = '{"errors":{"lang":["must be given"]}}'
          promise = @model.sync "create", @model
          promise.fail fail
          @respond @xhr, "error", "Unprocessible Entity"
          fail.should.have.been.calledOnce
          fail.should.have.been.calledOn @model
          fail.should.have.been.calledWith {errors: lang: ["must be given"]}, @xhr

        it "does not trigger done callbacks", ->
          done = sinon.spy()
          promise = @model.sync "create", @model
          promise.done done
          @respond @xhr, "error", "Unprocessible Entity"
          done.should.not.have.been.called

        it "fails gracefully when response text is not valid JSON", ->
          fail = sinon.spy()
          @xhr.responseText = "Me ain't JSON!"
          promise = @model.sync "create", @model
          promise.fail fail
          @respond @xhr, "error", "Unprocessible Entity"
          fail.should.have.been.calledWith {}, @xhr

        # it "triggers error event on model", ->
        #   spy = sinon.spy()
        #   @xhr.status = 422
        #   @xhr.responseText = '{"error":"is not valid"}'
        #   @model.on "error", spy
        #   @model.sync "create", @model
        #   @respond @xhr, "error", "Unprocessible Entity"
        #   spy.should.have.been.calledOnce
        #   spy.should.have.been.calledWith 422, "Unprocessible Entity", error: "is not valid", @xhr
