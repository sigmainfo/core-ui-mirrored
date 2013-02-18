#= require spec_helper
#= require models/term

describe "Coreon.Models.Term", ->

  beforeEach ->
    @model = new Coreon.Models.Term
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model
