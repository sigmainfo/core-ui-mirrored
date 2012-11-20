#= require spec_helper
#= require models/concept
#= require config/application
#= require collections/hits

describe "Coreon.Models.Concept", ->

  beforeEach ->
    @model = new Coreon.Models.Concept _id: "123"
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  it "is an accumulating model", ->
    Coreon.Models.Concept.find.should.equal Coreon.Modules.Accumulation.find

  it "has an URL root", ->
    @model.urlRoot.should.equal "concepts"

  context "defaults", ->

    it "has an empty set of properties", ->
      @model.get("properties").should.eql [] 

    it "has an empty set of terms", ->
      @model.get("terms").should.eql [] 

    it "has empty sets for superconcept and subconcept ids", ->
      @model.get("super_concept_ids").should.eql []
      @model.get("sub_concept_ids").should.eql []

  describe "#label", ->
    
    it "uses id when no label is given", ->
      @model.id = "abcd1234"
      @model.label().should.equal "abcd1234"

    it "uses label property when give", ->
      @model.id = "abcd1234"
      @model.set "properties", [
        key: "label"
        value: "poetry"
      ]  
      @model.label().should.equal "poetry"

  describe "#info", ->
    
    it "returns hash with system info attributes", ->
      @model.set
        _id: "abcd1234"
        author: "Nobody"
      @model.info().should.eql {
        id: "abcd1234"
        author: "Nobody"
      }


  describe "#fetch", ->

    it "uses application sync", ->
      Coreon.application = sync: sinon.spy()
      try
        @model.fetch()
        Coreon.application.sync.should.have.been.calledWith "read", @model
      finally
        Coreon.application = null
