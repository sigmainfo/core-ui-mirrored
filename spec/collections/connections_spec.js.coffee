#= require spec_helper
#= require collections/connections

describe "Coreon.Collections.Connections", ->
  
  beforeEach ->
    @connections = new Coreon.Collections.Connections

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
      @connections.length.should.equal 0
    
  describe "#sync", ->
    
    beforeEach ->
      Coreon.application = 
        account:
          get: (key) -> "123-my-auth-token-xxx" if key is "session"

      @xhr =
        abort: sinon.spy()
        fail: => @xhr
        always: ->

      sinon.stub Backbone, "sync"
      Backbone.sync.returns @xhr

    afterEach ->
      delete Coreon.application
      Backbone.sync.restore()

    it "sets auth header", ->
      @connections.sync "read", "model", data: "data" 
      @connections.at(0).get("options").headers.should.have.property "X-Core-Session", "123-my-auth-token-xxx"

    it "adds connection", ->
      @connections.sync "read", "model", data: "data"
      @connections.should.have.length 1
      @connections.at(0).get("xhr").should.equal @xhr
      @connections.at(0).get("options").should.have.property "data", "data"
      @connections.at(0).get("model").should.equal "model"
      @connections.at(0).get("method").should.equal "read"
    
