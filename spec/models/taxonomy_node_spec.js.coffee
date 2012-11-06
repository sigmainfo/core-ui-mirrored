#= require spec_helper
#= require models/taxonomy_node

describe "Coreon.Models.TaxonomyNode", ->

  beforeEach ->
    @node = new Coreon.Models.TaxonomyNode _id: "123"

  it "is a Backbone model", ->
    @node.should.be.an.instanceof Backbone.Model

  it "has empty properties array by default", ->
    @node.get("properties").should.eql []

  describe "#label", ->
    
    it "defaults to id", ->
      @node.id = "1234f"
      @node.label().should.equal "1234f"
      
    it "uses label property when given", ->
      @node.set "properties", [
        {
          key:   "label"
          value: "Wild West"
        }
      ]
      @node.label().should.equal "Wild West"
      
