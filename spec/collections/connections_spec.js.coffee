#= require spec_helper
#= require collections/connections

describe "Coreon.Collections.Connections", ->
  
  beforeEach ->
    @connections = new Coreon.Collections.Connections

  it "is a Backbone collection", ->
    @connections.should.be.an.instanceOf Backbone.Collection

  describe "#sync", ->
    
    beforeEach ->
      sinon.stub Backbone, "sync"

    afterEach ->
      Backbone.sync.restore()

    it "adds connection", ->
      Backbone.sync.returns "jqXHR"
      @connections.sync "read", "Model", data: "data"
      @connections.should.have.length 1
      @connections.at(0).get("xhr").should.equal "jqXHR"
      @connections.at(0).get("options").should.eql data: "data"
      @connections.at(0).get("model").should.equal "Model"
      @connections.at(0).get("method").should.equal "read"
    
