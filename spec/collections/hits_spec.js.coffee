#= require spec_helper
#= require collections/hits

describe "Coreon.Collections.Hits", ->

  context "class", ->

    it "creates instance", ->
      hits = Coreon.Collections.Hits.collection()
      hits.should.be.an.instanceof Coreon.Collections.Hits
      hits.should.have.lengthOf 0

    it "ensures single instance", ->
      Coreon.Collections.Hits.collection().should.equal Coreon.Collections.Hits.collection()
    
  context "instance", ->

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
      
