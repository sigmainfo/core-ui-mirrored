#= require spec_helper
#= require collections/hits

describe "Coreon.Collections.Hits", ->

  beforeEach ->
    @hits = new Coreon.Collections.Hits

  it "is a Backbone collection", ->
    @hits.should.be.an.instanceof Backbone.Collection

  it "uses Hit model", ->
    @hits.model.should.equal Coreon.Models.Hit
