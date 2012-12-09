#= require spec_helper
#= require models/concept
#= require config/application
#= require collections/hits

describe "Coreon.Models.Concept", ->

  beforeEach ->
    @model = new Coreon.Models.Concept _id: "123"
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  it "is an accumulating model", ->
    Coreon.Models.Concept.find.should.equal Coreon.Modules.Accumulation.find

  it "has an URL root", ->
    @model.urlRoot.should.equal "concepts"

  context "defaults", ->

    it "has an empty set of properties", ->
      @model.get("properties").should.eql [] 

    it "has an empty set of terms", ->
      @model.get("terms").should.eql [] 

    it "has empty sets for superconcept and subconcept ids", ->
      @model.get("super_concept_ids").should.eql []
      @model.get("sub_concept_ids").should.eql []

  describe "label()", ->
    
    it "uses id when no label is given", ->
      @model.id = "abcd1234"
      @model.label().should.equal "abcd1234"

    it "uses first English term when given", ->
      @model.set "terms", [
        {
          lang: "fr"
          value: "poésie"
        }
        {
          lang: "en"
          value: "poetry"
        }
      ], silent: true
      @model.label().should.equal "poetry"    

    it "uses first given term when no English term exists", ->
      @model.id = "abcd1234"
      @model.set "terms", [
        lang: "fr"
        value: "poésie"
      ], silent: true  
      @model.label().should.equal "poésie"

    it "uses label property when given", ->
      @model.id = "abcd1234"
      @model.set {
        terms: [
          lang: "en"
          value: "poetry"
        ]
        properties: [
          key: "label"
          value: "MyLabel"
        ]
      }, silent: true
      @model.label().should.equal "MyLabel"

    it "escapes label value", ->
      @model.set "properties", [
        key: "label"
        value: "<script>xss()</script>"
      ]
      @model.label().should.equal "&lt;script&gt;xss()&lt;&#x2F;script&gt;"

    it "handles term lang gracefully", ->
      @model.set "terms", [
        {
          lang: "fr"
          value: "poésie"
        }
        {
          lang: "EN_US"
          value: "poetry"
        }
      ], silent: true
      @model.label().should.equal "poetry" 


  describe "info()", ->
    
    it "returns hash with system info attributes", ->
      @model.set
        _id: "abcd1234"
        author: "Nobody"
      @model.info().should.eql {
        id: "abcd1234"
        author: "Nobody"
      }


  describe "fetch()", ->

    it "uses application sync", ->
      Coreon.application = sync: sinon.spy()
      try
        @model.fetch()
        Coreon.application.sync.should.have.been.calledWith "read", @model
      finally
        Coreon.application = null

  describe "hit()", ->

    beforeEach ->
      Coreon.application =
        hits: new Coreon.Collections.Hits

    afterEach ->
      Coreon.application = null
  
    it "returns false when not within hits", ->
      @model.hit().should.be.false

    it "returns true when within hits", ->
      Coreon.application.hits.add { id: @model.id }, silent: true
      @model.hit().should.be.true
