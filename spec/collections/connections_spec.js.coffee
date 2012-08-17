#= require spec_helper
#= require collections/connections

describe "Coreon.Collections.Connections", ->
  
  beforeEach ->
    @connections = new Coreon.Collections.Connections

  it "is a Backbone collection", ->
    @connections.should.be.an.instanceOf Backbone.Collection
