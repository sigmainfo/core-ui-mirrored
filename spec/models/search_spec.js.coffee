#= require spec_helper
#= require models/repository_cache
#= require models/search

describe "Coreon.Models.Search", ->
  
  beforeEach ->
    @model = new Coreon.Models.Search

  it "is a Backbone model", ->
    expect( @model ).to.be.an.instanceof Backbone.Model

  it "has an empty result set by default", ->
    expect( @model.get("hits") ).to.eql []

  describe "#params", ->

    beforeEach ->
      @repositoryCache = new Coreon.Models.RepositoryCache()
      
      Coreon.application =
        repositorySettings: => @repositoryCache
        
      @model.set query: "gun"
      
    afterEach ->
      delete Coreon.application
    
    it "generates params from data", ->
      @model.set query: "gun"
      @model.set target: "terms"
      expect( @model.params() ).to.eql
        "search[query]": "gun"
        "search[only]":  "terms"
        "search[tolerance]": 2

    it "skips target when not given", ->
      @model.unset "target"
      expect( @model.params() ).to.eql
        "search[query]": "gun"
        "search[tolerance]": 2

    it "prepends prefixes properties", ->
      @model.set target: "definition"
      expect( @model.params() ).to.eql
        "search[query]": "gun"
        "search[only]":  "properties/definition"
        "search[tolerance]": 2
         
    # it "adds source_language if set", ->
    #   @repositoryCache.set 'sourceLanguage', 'de', silent: true
    #           
    #   expect( @model.params() ).to.eql
    #     "search[query]": "gun"
    #     "search[tolerance]": 2
    #     "search[source_language]": 'de'
    #   
    # it "adds target_language if set", ->
    #   @repositoryCache.set 'targetLanguage', 'fr', silent: true
    #           
    #   expect( @model.params() ).to.eql
    #     "search[query]": "gun"
    #     "search[tolerance]": 2
    #     "search[target_language]": 'fr'
    #     
    # it "adds source and target language if both set", ->
    #   @repositoryCache.set 'sourceLanguage', 'de', silent: true
    #   @repositoryCache.set 'targetLanguage', 'fr', silent: true
    #   
    #   expect( @model.params() ).to.eql
    #     "search[query]": "gun"
    #     "search[tolerance]": 2
    #     "search[source_language]": 'de'
    #     "search[target_language]": 'fr'

  describe "sync()", ->

    it "delegates to core api sync", ->
      expect( @model.sync ).to.equal Coreon.Modules.CoreAPI.sync

  describe "fetch()", ->

    it "sends POST with params", ->
      @model.params = -> "search[only]": "terms" 
      @model.sync = sinon.spy()
      @model.fetch parse: yes
      expect( @model.sync ).to.have.been.calledOnce
      expect( @model.sync ).to.have.been.calledWith "read", @model
      expect( @model.sync.firstCall.args[2] ).to.have.property "method", "POST"
      expect( @model.sync.firstCall.args[2] ).to.have.property "parse", yes
      expect( @model.sync.firstCall.args[2] ).to.have.property "data"
      expect( @model.sync.firstCall.args[2].data ).to.have.property "search[only]", "terms"

  describe "#query", ->
    
    it "returns query component", ->
      @model.set 
        query: "poetry"
        target: "terms"
      expect( @model.query() ).to.equal "terms/poetry"

    it "skips target when not given", ->
      @model.set query: "poetry"
      expect( @model.query() ).to.equal "poetry"

    it "urlencodes values", ->
      @model.set query: "foo bar bäz"
      expect( @model.query() ).to.equal "foo%20bar%20b%C3%A4z"
      
    
