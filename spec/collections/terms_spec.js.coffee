#= require spec_helper
#= require collections/terms

describe "Coreon.Collections.Terms", ->

  beforeEach ->
    @collection = new Coreon.Collections.Terms

  it "is a backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "creates Term models", ->
    @collection.add id: "term"
    @collection.get("term").should.be.an.instanceof Coreon.Models.Term
  
  describe "toJSON()", ->

    it "strips wrapping objects from terms", ->
      @collection.reset [ value: "high hat", lang: "de", properties: [] ]
      @collection.toJSON().should.eql [ value: "high hat", lang: "de", properties: [] ]
