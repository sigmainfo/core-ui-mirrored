#= require spec_helper
#= require models/property

describe "Coreon.Models.Property", ->

  beforeEach ->
    @model = new Coreon.Models.Property
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.defaults = -> properties: []
      @model.set {
        _id: "abcd1234"
        author: "Nobody"
        properties: [ "foo" ]
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"
