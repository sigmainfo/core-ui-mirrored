#= require spec_helper
#= require models/term

describe "Coreon.Models.Term", ->

  beforeEach ->
    @model = new Coreon.Models.Term
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  context "defaults", ->

    it "has an empty set of properties", ->
      @model.get("properties").should.eql []

    it "has a value attribure", ->
      @model.get("value").should.eql ""

    it "has a lang attribure", ->
      @model.get("lang").should.eql ""

  describe "info()", ->
    
    it "returns hash with system info attributes", ->
      @model.set
        _id: "abcd1234"
        author: "Nobody"
        value: "something"
      @model.info().should.eql {
        id: "abcd1234"
        author: "Nobody"
      }
