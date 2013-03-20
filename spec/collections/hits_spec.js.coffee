#= require spec_helper
#= require collections/hits

describe "Coreon.Collections.Hits", ->

  beforeEach ->
    @hits = new Coreon.Collections.Hits

  it "is a Backbone collection", ->
    @hits.should.be.an.instanceof Backbone.Collection

  it "uses Hit model", ->
    @hits.model.should.equal Coreon.Models.Hit

  describe "findByResult", ->

    beforeEach ->
      @result = new Backbone.Model
  
    it "returns null when not found", ->
      expect(@hits.findByResult @result).to.be.null

    it "finds hit for result", ->
      @hits.reset [ result: @result ], silent: true
      @hits.findByResult(@result).get("result").should.equal @result
    
