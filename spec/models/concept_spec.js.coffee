#= require spec_helper
#= require models/concept
#= require config/application

describe "Coreon.Models.Concept", ->

  beforeEach ->
    @model = new Coreon.Models.Concept id: "123"
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  it "has an empty set of properties by default", ->
    @model.get("properties").should.eql [] 

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


  describe "#fetch", ->

    it "uses application sync", ->
      Coreon.application = sync: sinon.spy()
      try
        @model.fetch()
        Coreon.application.sync.should.have.been.calledWith "read", @model
      finally
        Coreon.application = null
