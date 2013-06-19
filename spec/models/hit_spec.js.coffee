#= require spec_helper

describe "Coreon.Models.Hit", ->

  context "class", ->
    
    describe "collection()", ->

      it "returns Hits collection", ->
        Coreon.Models.Hit.collection().should.be.an.instanceof Coreon.Collections.Hits

  context "instance", ->
    
    beforeEach ->
      @hit = new Coreon.Models.Hit _id: "1234"

    it "is a Backbone model", ->
      @hit.should.be.an.instanceof Backbone.Model

    it "has a default score of 0", ->
      @hit.get("score").should.equal 0
