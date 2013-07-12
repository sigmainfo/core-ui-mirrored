#= require spec_helper
#= require models/search

describe "Coreon.Models.Search", ->
  
  beforeEach ->
    @model = new Coreon.Models.Search

  it "is a Backbone model", ->
    @model.should.be.an.instanceof Backbone.Model

  it "has an empty result set by default", ->
    @model.get("hits").should.eql []

  describe "#params", ->

    beforeEach ->
      @model.set query: "gun"
    
    it "generates params from data", ->
      @model.set query: "gun"
      @model.set target: "terms"
      @model.params().should.eql
        "search[query]": "gun"
        "search[only]":  "terms"
        "search[tolerance]": 2

    it "skips target when not given", ->
      @model.unset "target"
      @model.params().should.eql
        "search[query]": "gun"
        "search[tolerance]": 2

    it "prepends prefixes properties", ->
      @model.set target: "definition"
      @model.params().should.eql
        "search[query]": "gun"
        "search[only]":  "properties/definition"
        "search[tolerance]": 2

  describe "sync()", ->

    it "delegates to core api sync", ->
      @model.sync.should.equal Coreon.Modules.CoreAPI.sync

  describe "fetch()", ->

    it "sends POST with params", ->
      @model.params = -> "search[only]": "terms" 
      @model.sync = sinon.spy()
      @model.fetch parse: yes
      @model.sync.should.have.been.calledOnce
      @model.sync.should.have.been.calledWith "read", @model
      @model.sync.firstCall.args[2].should.have.property "method", "POST"
      @model.sync.firstCall.args[2].should.have.property "parse", yes
      @model.sync.firstCall.args[2].should.have.property "data"
      @model.sync.firstCall.args[2].data.should.have.property "search[only]", "terms"

  describe "#query", ->
    
    it "returns query component", ->
      @model.set 
        query: "poetry"
        target: "terms"
      @model.query().should.equal "terms/poetry"

    it "skips target when not given", ->
      @model.set query: "poetry"
      @model.query().should.equal "poetry"

    it "urlencodes values", ->
      @model.set query: "foo bar bäz"
      @model.query().should.equal "foo%20bar%20b%C3%A4z"
      
    
