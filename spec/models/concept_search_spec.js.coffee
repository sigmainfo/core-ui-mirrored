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
        sync: ->
        hits: new Backbone.Collection
      @promise =
        done: ->
      sinon.stub(Coreon.Models.Search::, "fetch").returns @promise

    afterEach ->
      Coreon.application = null
      Coreon.Models.Search::fetch.restore()

    it "calls super", ->
      callback = ->
      @search.fetch success: callback
      Coreon.Models.Search::fetch.should.have.been.calledWith success: callback

    context "done", ->

      beforeEach ->
        @promise.done = (@done) =>
        @search.fetch()
  
      it "updates concepts", ->
        @done 
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
        concept = Coreon.Models.Concept.find "1234"
        concept.get("properties").should.eql [{key: "label", value: "poet"}]
        concept.get("super_concept_ids").should.eql ["5047774cd19879479b000523", "5047774cd19879479b00002b"]


      it "updates current hits", ->
        @done
          hits: [
            {
              score: 1.56
              result:
                _id: "1234"
            }
          ]
        Coreon.application.hits.should.have.length 1
        should.exist Coreon.application.hits.get "1234"
      
