#= require spec_helper
#= require models/repository

describe "Coreon.Models.Repository", ->

  beforeEach ->
    @model = new Coreon.Models.Repository

  it "is a Backbone model", ->
    @model.should.be.an.instanceof Backbone.Model

  context "defaults", ->

    it "creates empty set for managers", ->
      @model.get("managers").should.eql []
    
