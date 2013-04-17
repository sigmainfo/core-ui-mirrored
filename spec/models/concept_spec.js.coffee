#= require spec_helper
#= require models/concept
#= require collections/hits

describe "Coreon.Models.Concept", ->

  beforeEach ->
    sinon.stub I18n, "t"
    Coreon.application = hits: new Backbone.Collection []
    Coreon.application.hits.findByResult = -> null
    @model = new Coreon.Models.Concept _id: "123"

  afterEach ->
    I18n.t.restore()
    Coreon.application = null
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  it "is an accumulating model", ->
    Coreon.Models.Concept.find.should.equal Coreon.Modules.Accumulation.find

  it "has an URL root", ->
    @model.urlRoot.should.equal "concepts"

  context "defaults", ->

    it "has an empty set for relations", ->
      @model.get("properties").should.eql []
      @model.get("terms").should.eql []

    it "has empty sets for superconcept and subconcept ids", ->
      @model.get("super_concept_ids").should.eql []
      @model.get("sub_concept_ids").should.eql []

  describe "attributes", ->

    describe "label", ->

      context "when newly created", ->

        it "defaults to <new concept>", ->
          @model.isNew = sinon.stub().returns true
          I18n.t.withArgs("concept.new_concept").returns "<new concept>"
          @model.set terms: [
              lang: "en"
              value: "flower"
            ], properties: [
              key: "label"
              value: "gun"
            ]
          @model.initialize()
          @model.get("label").should.equal "<new concept>"

      context "after save", ->

        it "uses first English term", ->
          @model.set terms: [
              {
                lang: "fr"
                value: "poésie"
              }
              {
                lang: "en"
                value: "poetry"
              }
              {
                lang: "en"
                value: "poetics"
              }
            ]
          @model.initialize()
          @model.get("label").should.equal "poetry"

        it "falls back to term in other language", ->
          @model.set terms: [
            lang: "fr"
            value: "poésie"
          ]
          @model.initialize()
          @model.get("label").should.equal "poésie"

        it "is overwritten by property", ->
          @model.set {
            properties: [
              key: "label"
              value: "My_label"
            ]
            terms: [
              lang: "en"
              value: "poetry"
            ]
          }, silent: true
          @model.initialize()
          @model.get("label").should.equal "My_label"

        it "handles term lang gracefully", ->
          @model.set terms: [
            {
              lang: "fr"
              value: "poésie"
            }
            {
              lang: "EN_US"
              value: "poetry"
            }
          ]
          @model.initialize()
          @model.get("label").should.equal "poetry"

      context "on changes", ->

        it "updates label on id attribute changes", ->
          @model.set "_id", "abc123"
          @model.get("label").should.equal "abc123"
            
        it "updates label on property changes", ->
          @model.set "properties", [
            key: "label"
            value: "My Label"
          ]
          @model.get("label").should.equal "My Label"
     
        it "updates label on term changes", ->
          @model.set "terms", [
            lang: "en"
            value: "poetry"
          ]
          @model.get("label").should.equal "poetry"
          

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

  describe "properties()", ->
    
    it "syncs with attr", ->
      @model.set "properties", [key: "label"]
      @model.properties().at(0).get("key").should.equal "label"
      
  describe "terms()", ->
  
    it "syncs with attr", ->
      @model.set "terms", [value: "dead", lang: "en"]
      @model.terms().at(0).should.be.an.instanceof Coreon.Models.Term
      @model.terms().at(0).get("value").should.equal "dead"

  describe "info()", ->
    
    it "returns hash with system info attributes", ->
      @model.set
        _id: "abcd1234"
        author: "Nobody"
      @model.info().should.eql {
        id: "abcd1234"
        author: "Nobody"
      }

  describe "toJSON()", ->

    it "returns wrapped attributes hash", ->
      @model.set
        _id: "my-concept"
        super_concept_ids: [ "super_1", "super_2" ]
        sub_concept_ids: [ "sub_1", "sub_2" ]
      json = @model.toJSON()
      json.should.have.deep.property "concept._id", "my-concept"
      json.should.have.deep.property("concept.super_concept_ids").that.eql [ "super_1", "super_2" ]
      json.should.have.deep.property("concept.sub_concept_ids").that.eql [ "sub_1", "sub_2" ]

    it "drops client-side attributes", ->
      @model.toJSON().should.not.have.deep.property "concept.label"
      @model.toJSON().should.not.have.deep.property "concept.hit"

  describe "save()", ->

    it "uses application sync with method 'update' if model exists", ->
      Coreon.application = sync: sinon.spy()
      try
        @model.save()
        Coreon.application.sync.should.have.been.calledWith "update", @model
      finally
        Coreon.application = null

    it "uses application sync with method 'create' if model is new", ->
      @model = new Coreon.Models.Concept
      Coreon.application = sync: sinon.spy()
      try
        @model.save()
        Coreon.application.sync.should.have.been.calledWith "create", @model
      finally
        Coreon.application = null
