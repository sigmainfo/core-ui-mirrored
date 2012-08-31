#= require spec_helper
#= require models/concept

describe "Coreon.Models.Concept", ->

  beforeEach ->
    @model = new Coreon.Models.Concept
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model
