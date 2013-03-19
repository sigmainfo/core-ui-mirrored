#= require spec_helper
#= require models/hit

describe "Coreon.Models.Hit", ->

  beforeEach ->
    @hit = new Coreon.Models.Hit _id: "1234"

  it "is a Backbone model", ->
    @hit.should.be.an.instanceof Backbone.Model

  it "has a default score of 0", ->
    @hit.get("score").should.equal 0
