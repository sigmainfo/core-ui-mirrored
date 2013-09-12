#= require spec_helper
#= require models/property

describe "Coreon.Models.Property", ->

  beforeEach ->
    @model = new Coreon.Models.Property
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  describe "defaults()", ->
  
    it "returns a hash of standard attrs", ->
      @model.defaults().should.eql
        key: ""
        value: ""
        lang: ""

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.defaults = ->
        key: ""
        value: ""
        lang: ""
      @model.set {
        id: "abcd1234"
        author: "Nobody"
        key: "label"
        value: "hat"
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"
