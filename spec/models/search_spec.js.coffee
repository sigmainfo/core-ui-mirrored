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

    it "skips target when not given", ->
      @model.unset "target"
      @model.params().should.eql
        "search[query]": "gun"

    it "prepends prefixes properties", ->
      @model.set target: "definition"
      @model.params().should.eql
        "search[query]": "gun"
        "search[only]":  "properties/definition"

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
      @request.requestBody.should.equal "search%5Bquery%5D=poet"

  describe "#query", ->
    
    it "returns query string", ->
      @model.set 
        query: "poetry"
        target: "terms"
      @model.query().should.equal "t=terms&q=poetry"

    it "skips target when not given", ->
      @model.set query: "poetry"
      @model.query().should.equal "q=poetry"

    it "urlencodes values", ->
      @model.set query: "[foo]"
      @model.query().should.equal "q=%5Bfoo%5D"
      
    
