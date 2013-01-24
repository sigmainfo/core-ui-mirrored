#= require spec_helper
#= require models/hit

describe "Coreon.Models.Hit", ->

  beforeEach ->
    @hit = new Coreon.Models.Hit id: "1234"

  it "is a Backbone model", ->
    @hit.should.be.an.instanceof Backbone.Model

  it "has a default score of 0", ->
    @hit.get("score").should.equal 0

  it "uses simple id attribute", ->
    @hit.id.should.equal "1234"

  describe "#validate", ->

    it "enforces id", ->
      @hit.isValid().should.be.true
      @hit.id = null
      @hit.isValid().should.be.false
