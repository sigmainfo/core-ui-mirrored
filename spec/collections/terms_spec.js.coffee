#= require spec_helper
#= require collections/terms

describe "Coreon.Collections.Terms", ->

  beforeEach ->
    @collection = new Coreon.Collections.Terms

  it "is a backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "creates Term models", ->
    @collection.add _id: "term"
    @collection.get("term").should.be.an.instanceof Coreon.Models.Term

  #it "can be initialized" 


