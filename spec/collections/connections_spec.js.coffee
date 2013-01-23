#= require spec_helper
#= require collections/connections

describe "Coreon.Collections.Connections", ->
  
  beforeEach ->
    @connections = new Coreon.Collections.Connections
    @connections.account = new Backbone.Model
      session: "123-my-auth-token-xxx"
      graph_root: "https://graph.coreon.com/"


  it "is a Backbone collection", ->
    @connections.should.be.an.instanceOf Backbone.Collection

  describe "#destroy", ->

    it "cancels all", ->
      xhr1 =
        abort: sinon.spy()
        fail: -> xhr1
        always: ->
      xhr2 =
        abort: sinon.spy()
        fail: -> xhr2
        always: ->
      @connections.add xhr: xhr1      
      @connections.add xhr: xhr2      
      @connections.destroy()
      xhr1.abort.should.have.been.calledOnce
      xhr2.abort.should.have.been.calledOnce

    it "resets collection", ->
      xhr =
        abort: sinon.spy()
        fail: -> xhr
        always: ->
      sinon.spy @connections, "reset"
      @connections.add xhr: xhr
      @connections.destroy()
      @connections.reset.should.have.been.calledOnce
      @connections.should.have.lengthOf 0

  describe "#sync", ->
    
    beforeEach ->
      @model = new Backbone.Model
      @model.url = "models/123"
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "generates graph url from url property", ->
      @model.url = "models/123"
      @connections.sync "read", @model
      @request.url.should.equal "https://graph.coreon.com/models/123"

    it "generates graph url from url method", ->
      @model.url = -> "models/123"
      @connections.sync "read", @model
      @request.url.should.equal "https://graph.coreon.com/models/123"

    it "allows overriding url", ->
      @connections.sync "read", @model, url: "some/url"
      @request.url.should.equal "some/url"

    it "sets auth header", ->
      @connections.account.set "session", "123-my-token-xxx"
      @connections.sync "read", @model, url: "some/url"
      @request.requestHeaders.should.have.property "X-Core-Session", "123-my-token-xxx"

    it "adds connection to collection", ->
      jqXHR = @connections.sync "read", @model, data: "I'm not dead. Am I?"
      @connections.should.have.lengthOf 1 
      @connections.at(0).get("xhr").should.equal jqXHR 
      @connections.at(0).get("method").should.equal "read" 
      @connections.at(0).get("model").should.equal @model 
      @connections.at(0).get("options").should.have.property "data", "I'm not dead. Am I?"
