#= require spec_helper
#= require models/search
#= require config/application

describe "Coreon.Models.Search", ->
  
  beforeEach ->
    Coreon.application = new Coreon.Application
    @model = new Coreon.Models.Search

  afterEach ->
    Coreon.application.destroy()

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

  describe "#fetch", ->

    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (@request) =>

    afterEach ->
      @xhr.restore()

    it "creates request", ->
      Coreon.application.account.set "graph_root", "https://graph.coreon.com/"
      @model.set
        path:  "terms/search"
        query: "poet"
      @model.fetch()
      @request.url.should.equal "https://graph.coreon.com/terms/search"
      @request.method.should.equal "POST"
      @request.requestBody.should.equal "search%5Bquery%5D=poet&search%5Btolerance%5D=2"

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
      
    
