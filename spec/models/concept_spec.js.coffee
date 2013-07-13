#= require spec_helper
#= require models/concept

describe "Coreon.Models.Concept", ->

  beforeEach ->
    @hits = new Backbone.Collection
    @hits.findByResult = -> null
    sinon.stub Coreon.Collections.Hits, "collection", => @hits
    @model = new Coreon.Models.Concept _id: "123"

  afterEach ->
    Coreon.Collections.Hits.collection.restore()

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  it "is an accumulating model", ->
    Coreon.Models.Concept.find.should.equal Coreon.Modules.Accumulation.find

  it "has an URL root", ->
    @model.urlRoot.should.equal "/concepts"

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

        beforeEach ->
          sinon.stub I18n, "t"
          I18n.t.withArgs("concept.new_concept").returns "<new concept>"
          @model.isNew = -> true

        afterEach ->
          I18n.t.restore()

        it "defaults to <new concept>", ->
          @model.set properties: [ key: "label", value: "gun" ]
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
        @hits.add _id: "hit", result: @model
        @hit = @hits.at 0
        @hits.findByResult = (result) =>
          for hit in @hits.models
            return hit if hit.get("result") is result
          null
        @model.initialize()

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
      @model.properties().at(0).should.be.an.instanceof Coreon.Models.Property
      @model.properties().at(0).get("key").should.equal "label"

  describe "terms()", ->

    it "creates terms from attr", ->
      @model.set "terms", [value: "dead", lang: "en"]
      @model.terms().at(0).should.be.an.instanceof Coreon.Models.Term
      @model.terms().at(0).get("value").should.equal "dead"

    it "updates attr from terms", ->
      @model.terms().reset [ value: "dead", lang: "en", properties: [] ]
      @model.get("terms").should.eql [ value: "dead", lang: "en", properties: [] ]

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.set {
        _id: "abcd1234"
        author: "Nobody"
        terms : [ "foo", "bar" ]
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"

  describe "propertiesByKey()", ->

    it "returns empty hash when empty", ->
      @model.properties = -> models: []
      @model.propertiesByKey().should.eql {}

    it "returns properties grouped by key", ->
      prop1 = new Backbone.Model key: "label"
      prop2 = new Backbone.Model key: "definition"
      prop3 = new Backbone.Model key: "definition"
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      @model.propertiesByKey().should.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]

  describe "termsByLang()", ->

    it "returns empty hash when empty", ->
      @model.terms = -> models: []
      @model.termsByLang().should.eql {}

    it "returns terms grouped by lang", ->
      term1 = new Backbone.Model lang: "en"
      term2 = new Backbone.Model lang: "de"
      term3 = new Backbone.Model lang: "de"
      @model.terms = -> models: [ term1, term2, term3 ]
      @model.termsByLang().should.eql
        en: [ term1 ]
        de: [ term2, term3 ]

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

    it "does not create wrapper for terms", ->
      @model.terms().reset [ { value: "hat" }, { value: "top hat" } ]
      @model.toJSON().should.have.deep.property "concept.terms[0].value", "hat"
      @model.toJSON().should.have.deep.property "concept.terms[1].value", "top hat"

  describe "fetch()", ->

      beforeEach ->
        sinon.stub Coreon.Modules.CoreAPI, "sync"

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()
      
      it "combines multiple subsequent calls into a single batch request", ->
        @model.fetch()
        Coreon.Modules.CoreAPI.sync.should.have.been.calledOnce
        Coreon.Modules.CoreAPI.sync.firstCall.args[2].should.have.property "batch", on
        

    

  describe "save()", ->

    context "application sync", ->

      beforeEach ->
        sinon.stub Coreon.Modules.CoreAPI, "sync"

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it "delegates to application sync", ->
        @model.save {}, wait: true
        Coreon.Modules.CoreAPI.sync.should.have.been.calledOnce
        Coreon.Modules.CoreAPI.sync.should.have.been.calledWith "update", @model
        Coreon.Modules.CoreAPI.sync.firstCall.args[2].should.have.property "wait", true

    context "create", ->

      beforeEach ->
        @model.id = null
        sinon.stub Coreon.Modules.CoreAPI, "sync", (method, model, options = {}) ->
          model.id = "1234"
          options.success?()

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it "triggers custom event", ->
        spy = sinon.spy()
        @model.on "create", spy
        @model.save "label", "dead man"
        @model.save "label", "nobody"
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith @model, @model.id

  describe "errors()", ->

    it "collects remote validation errors", ->
      @model.trigger "error", @model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      @model.errors().should.eql
        foo: ["must be bar"]

  describe "revert()", ->

    it "can restore last persisted state", ->
      @model.set "label", "high hat", silent: true
      @model.trigger "sync"
      @model.set "label", "xxxx", silent: true
      @model.set "label", "****", silent: true
      @model.revert()
      @model.get("label").should.equal "high hat"

