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

  describe "properties()", ->
    
    it "syncs with attr", ->
      @model.set "properties", [key: "label"]
      @model.properties().at(0).should.be.an.instanceof Coreon.Models.Property
      @model.properties().at(0).get("key").should.equal "label"

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.set {
        _id: "abcd1234"
        author: "Nobody"
        properties : [ "foo", "bar" ]
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"

  describe "propertiesByKey()", ->

    it "returns empty hash when empty", ->
      @model.properties = -> models: []
      @model.propertiesByKey().should.eql {}

    it "returns properties grouped by key", ->
      prop1 = new Backbone.Model key: "label"
      prop2 = new Backbone.Model key: "definition"
      prop3 = new Backbone.Model key: "definition"
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      @model.propertiesByKey().should.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]


