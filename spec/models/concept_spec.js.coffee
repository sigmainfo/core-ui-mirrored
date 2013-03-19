#= require spec_helper
#= require models/concept
#= require collections/hits

describe "Coreon.Models.Concept", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @model = new Coreon.Models.Concept _id: "123"

  afterEach ->
    I18n.t.restore()
  
  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  it "is an accumulating model", ->
    Coreon.Models.Concept.find.should.equal Coreon.Modules.Accumulation.find

  it "has an URL root", ->
    @model.urlRoot.should.equal "concepts"

  context "defaults", ->

    it "has an empty set of properties", ->
      @model.get("properties").should.eql []

    it "has a empty term collection", ->
      @model.get("terms").should.be.an.instanceof Coreon.Collections.Terms
      @model.get("terms").should.have.length 0

    it "has empty sets for superconcept and subconcept ids", ->
      @model.get("super_concept_ids").should.eql []
      @model.get("sub_concept_ids").should.eql []

  describe "attributes", ->

    describe "terms", ->

      describe "initialization", ->

        it "can be created from json construtor argument", ->
          @model = new Coreon.Models.Concept _id: "123", terms:
            lang: "en"
            value: "poetry"
          @model.get("terms").should.be.an.instanceof Coreon.Collections.Terms
          @model.get("terms").should.have.length 1
          @model.get("terms").at(0).should.be.an.instanceof Coreon.Models.Term
          @model.get("terms").at(0).get("lang").should.eql "en"
          @model.get("terms").at(0).get("value").should.eql "poetry"

        it "can be created from object construtor argument", ->
          @model = new Coreon.Models.Concept _id: "123", terms: new Coreon.Collections.Terms
            lang: "en"
            value: "poetry"
          @model.get("terms").should.be.an.instanceof Coreon.Collections.Terms
          @model.get("terms").should.have.length 1
          @model.get("terms").at(0).should.be.an.instanceof Coreon.Models.Term
          @model.get("terms").at(0).get("lang").should.eql "en"
          @model.get("terms").at(0).get("value").should.eql "poetry"

      describe "events", ->

        context "on add terms", ->

          it "triggers change:terms", ->
            spy = sinon.spy()
            @model.on "change:terms", spy
            @model.get("terms").add
              lang: "en"
              value: "poetry"
            spy.should.have.been.calledOnce

          it "triggers add:terms", ->
            spy = sinon.spy()
            @model.on "add:terms", spy
            @model.get("terms").add
              lang: "en"
              value: "poetry"
            spy.should.have.been.calledOnce

        context "on remove terms", ->

          it "triggers change:terms", ->
            @model.get("terms").add lang: "en", value: "poetry"
            spy = sinon.spy()
            @model.on "change:terms", spy
            @model.get("terms").pop()
            spy.should.have.been.calledOnce

          it "triggers remove:terms", ->
            @model.get("terms").add lang: "en", value: "poetry"
            spy = sinon.spy()
            @model.on "remove:terms", spy
            @model.get("terms").pop()
            spy.should.have.been.calledOnce

        context "on change terms", ->

          it "triggers change:terms", ->
            @model.get("terms").add lang: "en", value: "poetry"
            spy = sinon.spy()
            @model.on "change:terms", spy
            @model.get("terms").at(0).set "value", "poetics"
            spy.should.have.been.calledOnce

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
          @model.set terms:
            lang: "fr"
            value: "poésie"
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
            
        it "updates label on property changes", ->
          @model.set "properties", [
            key: "label"
            value: "My Label"
          ]
          @model.get("label").should.equal "My Label"
     
        it "updates label on term change", ->
          @model.get("terms").add
            lang: "en"
            value: "poetry"
          @model.get("label").should.equal "poetry"

  describe "hit", ->
     
    beforeEach ->
      @hits = new Backbone.Collection [ _id: "hit" ]
      @hit = @hits.get "hit"
      Coreon.application =
        hits: @hits
      @model.id = "hit"
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
      @model.id = "foo"
      @hits.add _id: "foo"
      hit = @hits.get "foo"
      @model.get("hit").should.equal hit

  describe "set()", ->

    it "handles json (as hash)", ->
      @model.set "terms":
        lang: "en"
        value: "poetry"
      @model.get("terms").should.have.length 1
      @model.get("terms").at(0).toJSON().should.be.eql
        lang: 'en'
        value: 'poetry'
        properties: []

    it "handles json (as key-value)", ->
      @model.set "terms",
        lang: "en"
        value: "poetry"
      @model.get("terms").should.have.length 1
      @model.get("terms").at(0).toJSON().should.be.eql
        lang: 'en'
        value: 'poetry'
        properties: []

    it "handles object (as hash)", ->
      @model.set "terms": new Coreon.Collections.Terms
        lang: "en"
        value: "poetry"
      @model.get("terms").should.have.length 1
      @model.get("terms").at(0).toJSON().should.be.eql
        lang: 'en',
        value: 'poetry',
        properties: []

    it "handles object (as key-value)", ->
      @model.set "terms", new Coreon.Collections.Terms
        lang: "en"
        value: "poetry"
      @model.get("terms").should.have.length 1
      @model.get("terms").at(0).toJSON().should.be.eql
        lang: 'en',
        value: 'poetry',
        properties: []

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

  describe "addTerm()", ->

    it "creates a new empty term model", ->
      @model.addTerm()
      @model.get("terms").size().should.be.eql 1

    it "creates a term model which knows about its terms conncetion", ->
      @model.addTerm()
      @model.get("terms").at(0).collection.should.eql @model.get("terms")

  describe "addProperty()", ->

    it "creates a new empty property model", ->
      @model.addProperty()
      @model.get("properties").length.should.be.eql 1

  describe "create()", ->

    it "calls create() on the class", ->
      Coreon.Models.Concept.create = sinon.spy()
      @model.create()
      Coreon.Models.Concept.create.withArgs( @model,
        success: @model.onSuccess
        error: @model.onError ).should.have.been.calledOnce

  describe "toJSON()", ->

    it "adds an outer hash with concept: as key", ->
      JSON.stringify(@model.toJSON()).should.equal JSON.stringify( concept: _.omit @model.attributes, "label" )

    it "ignores label attribute", ->
      @model.toJSON().should.not.have.property "label"

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

  describe "onSuccess()", ->

    it "is triggered by successfull save()", ->
      Coreon.Models.Concept.create = (data, opts) ->
        opts.success()
      @model.onSuccess = sinon.spy()
      @model.create()
      @model.onSuccess.should.have.been.calledOnce

    it "navigates to concept view page", ->
      Backbone.history.navigate = sinon.spy()
      @model.set "_id", 42
      @model.onSuccess()
      Backbone.history.navigate.withArgs( "concepts/42", replace: true, trigger: true ).should.have.been.calledOnce

  describe "onError()", ->

    it "is triggered by save() error", ->
      Coreon.Models.Concept.create = (data, opts) ->
        opts.error()
      @model.onError = sinon.spy()
      @model.create()
      @model.onError.should.have.been.calledOnce

    it "triggers validationFailure()", ->
      @model.validationFailure = sinon.spy()
      @model.onError @model,
        status: 422
        responseText: '{"errors": {"foo": "bar"}}'
      @model.validationFailure.withArgs( foo: 'bar' ).should.have.been.calledOnce

  describe "validationFailure()", ->

    it "triggers validationFailure event", ->
      spy = sinon.spy()
      @model.on "validationFailure", spy
      @model.validationFailure( foo: 'bar' )
      spy.withArgs( foo: 'bar' ).should.have.been.calledOnce

