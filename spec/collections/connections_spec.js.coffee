#= require spec_helper
#= require collections/connections

describe "Coreon.Collections.Connections", ->
  
  beforeEach ->
    @connections = new Coreon.Collections.Connections

  it "is a Backbone collection", ->
    @connections.should.be.an.instanceOf Backbone.Collection

  describe "#destroy", ->

    it "cancels all", ->
      xhr1 = abort: sinon.spy(), fail: ->
      xhr2 = abort: sinon.spy(), fail: ->
      @connections.add xhr: xhr1      
      @connections.add xhr: xhr2      
      @connections.destroy()
      xhr1.abort.should.have.been.calledOnce
      xhr2.abort.should.have.been.calledOnce

    it "resets collection", ->
      sinon.spy @connections, "reset"
      @connections.add xhr:
        abort: ->
        fail: ->      
      @connections.destroy()
      @connections.reset.should.have.been.calledOnce
      @connections.length.should.equal 0
    
  describe "#sync", ->
    
    beforeEach ->
      sinon.stub Backbone, "sync"

    afterEach ->
      Backbone.sync.restore()

    it "adds connection", ->
      xhr = fail: ->
      Backbone.sync.returns xhr
      @connections.sync "read", "Model", data: "data"
      @connections.should.have.length 1
      @connections.at(0).get("xhr").should.equal xhr
      @connections.at(0).get("options").should.eql data: "data"
      @connections.at(0).get("model").should.equal "Model"
      @connections.at(0).get("method").should.equal "read"
    
