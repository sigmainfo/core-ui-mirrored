#= require spec_helper
#= require models/concept
#= require collections/hits

describe "Coreon.Models.Concept", ->

  beforeEach ->
    Coreon.application = hits: new Backbone.Collection []
    Coreon.application.hits.findByResult = -> null
    @model = new Coreon.Models.Concept _id: "123"

  afterEach ->
    Coreon.application = null
  
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

  describe "attributes", ->
  
    describe "label", ->

      context "when created", ->

        it "defaults to id", ->
          @model.id = "#abcdef"
          @model.initialize()
          @model.get("label").should.equal "#abcdef"

        it "uses first English term", ->
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
          @model.initialize()
          @model.get("label").should.equal "poetry"

        it "falls back to term in other language", ->
          @model.set "terms", [
            lang: "fr"
            value: "poésie"
          ], silent: true
          @model.initialize()
          @model.get("label").should.equal "poésie"

        it "is overwritten by property", ->
          @model.set {
            terms: [
              lang: "en"
              value: "poetry"
            ]
            properties: [
              key: "label"
              value: "My_label"
            ]
          }, silent: true
          @model.initialize()
          @model.get("label").should.equal "My_label"

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
          @model.initialize()
          @model.get("label").should.equal "poetry"

      context "on changes", ->
       
        it "updates label on term changes", ->
          @model.set "terms", [
            lang: "en"
            value: "poetry"
          ]
          @model.get("label").should.equal "poetry"
            
        it "updates label on property changes", ->
          @model.set "properties", [
            key: "label"
            value: "My Label"
          ]
          @model.get("label").should.equal "My Label"

    describe "hit", ->
       
      beforeEach ->
        @hits = new Backbone.Collection [ _id: "hit", result: @model ]
        @hit = @hits.at 0
        @hits.findByResult = (result) =>
          for hit in @hits.models
            return hit if hit.get("result") is result
          null
        Coreon.application =
          hits: @hits
        @model.initialize()
          
      afterEach ->
        Coreon.application = null
      
      it "gets hit from id", ->
        @model.get("hit").should.equal @hit

      it "updates hit on reset", ->
        @hits.reset []
        expect(@model.get "hit").to.be.null

      it "updates hit on remove", ->
        @hits.remove @hit
        expect(@model.get "hit").to.be.null

      it "updates hit when added", ->
        other = new Backbone.Model 
        @hits.add result: other
        added = hit for hit in @hits.models when hit.get("result") is @model
        @model.get("hit").should.equal added
        
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
