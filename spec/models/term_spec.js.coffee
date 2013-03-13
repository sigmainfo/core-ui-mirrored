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

    it "has an empty value attribure", ->
      @model.get("value").should.eql ""

    it "has an empty lang attribure", ->
      @model.get("lang").should.eql ""

    it "has an empty concept_id attribure", ->
      @model.get("lang").should.eql ""

  describe "info()", ->
    
    it "returns hash with system info attributes", ->
      @model.set
        _id: "abcd1234"
        author: "Nobody"
        value: "something"
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"

  describe "toJSON()", ->

    it "adds an outer hash with term: as key", ->
      @model.set "concept_id", 1
      @model.toJSON().should.eql
        properties: []
        value: ""
        lang: ""
        concept_id: 1

    it "filters out empty concept_ids", ->
      @model.toJSON().should.eql
        properties: []
        value: ""
        lang: ""

  describe "validationFailure()", ->

    it "triggers validationFailure event", ->
      spy = sinon.spy()
      @model.on "validationFailure", spy
      @model.validationFailure( foo: "bar" )
      spy.withArgs( foo: "bar" ).should.have.been.calledOnce


