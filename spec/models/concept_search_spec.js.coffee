#= require spec_helper
#= require models/concept_search

describe "Coreon.Models.ConceptSearch", ->

  beforeEach ->
    @search = new Coreon.Models.ConceptSearch

  it "is a Search", ->
    @search.should.be.an.instanceof Coreon.Models.Search

  describe "fetch()", ->

    beforeEach ->
      Coreon.application =
        get: ->
          get: -> "coffee"
        sync: ->
          done: ->
        hits: new Backbone.Collection
        graphUri: -> "coffeebabe23"
      Coreon.application.hits.findByResult = -> null
      sinon.stub Coreon.Models.Search::, "fetch"

    afterEach ->
      Coreon.application = null
      Coreon.Models.Search::fetch.restore()

    it "calls super", ->
      @search.fetch foo: "bar"
      Coreon.Models.Search::fetch.should.have.been.calledWithMatch foo: "bar"

    context "success", ->

      it "calls passed callback", ->
        Coreon.Models.Search::fetch.yieldsTo "success", @search, hits: []
        spy = sinon.spy()
        @search.fetch success: spy
        spy.should.have.been.calledOnce

      it "updates concepts", ->
        Coreon.Models.Search::fetch.yieldsTo "success", @search,
          hits: [
            {
              score: 1.56
              result:
                _id: "1234"
                properties: [
                  { key: "label", value: "poet" }
                ]
                super_concept_ids: [
                  "5047774cd19879479b000523"
                  "5047774cd19879479b00002b"
                ]
            }
          ]
        @search.fetch()
        concept = Coreon.Models.Concept.find "1234"
        concept.get("properties").should.eql [{key: "label", value: "poet"}]
        concept.get("super_concept_ids").should.eql ["5047774cd19879479b000523", "5047774cd19879479b00002b"]


      it "updates current hits", ->
        Coreon.Models.Search::fetch.yieldsTo "success", @search,
          hits: [
            {
              score: 1.56
              result:
                _id: "1234"
            }
          ]
        @search.fetch()
        hits = Coreon.Collections.Hits.collection()
        hits.should.have.length 1
        hits.at(0).get("result").should.have.property "id", "1234"
