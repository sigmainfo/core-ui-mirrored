#= require spec_helper
#= require models/hit

describe "Coreon.Models.Hit", ->

  beforeEach ->
    @hit = new Coreon.Models.Hit id: "1234"

  it "is a Backbone model", ->
    @hit.should.be.an.instanceof Backbone.Model

  describe "defaults", ->
  
    it "has score of 0", ->
      @hit.get("score").should.equal 0

    it "has no result", ->
      should.equal @hit.get("result"), null
      
