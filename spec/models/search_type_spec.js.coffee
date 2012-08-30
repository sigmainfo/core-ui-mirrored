#= require spec_helper
#= require models/search_type

describe "Coreon.Models.SearchType", ->
  
  beforeEach ->
    @model = new Coreon.Models.SearchType

  it "is a Backbone model", ->
    @model.should.be.an.instanceof Backbone.Model

  it "has default availableTypes", ->
    @model.get("availableTypes").should.eql ["all", "definition", "terms"]

  it "has first type selected by default", ->
    @model.get("selectedTypeIndex").should.equal 0

  describe "#getSelectedType", ->

    it "returns type at index", ->
      @model.set
        availableTypes: ["foo", "bar", "baz"]
        selectedTypeIndex: 1
      @model.getSelectedType().should.equal "bar"
    
    
    
  
