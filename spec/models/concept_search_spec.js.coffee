#= require spec_helper
#= require models/concept_search

describe 'Coreon.Models.ConceptSearch', ->

  beforeEach ->
    @search = new Coreon.Models.ConceptSearch

  it 'is a Search', ->
    @search.should.be.an.instanceof Coreon.Models.Search

  context 'defaults', ->

    it 'searches within concepts', ->
      expect( @search.get 'path' ).to.equal 'concepts/search'

  describe '#fetch()', ->

    beforeEach ->
      sinon.stub Coreon.Models.Search::, 'fetch'
      sinon.stub Coreon.Models.Concept, 'upsert'

    afterEach ->
      Coreon.Models.Search::fetch.restore()
      Coreon.Models.Concept.upsert.restore()

    it 'calls super', ->
      @search.fetch foo: 'bar'
      Coreon.Models.Search::fetch.should.have.been.calledWithMatch foo: 'bar'

    context 'success', ->

      it 'calls passed callback', ->
        Coreon.Models.Search::fetch.yieldsTo 'success', @search, hits: []
        spy = sinon.spy()
        @search.fetch success: spy
        spy.should.have.been.calledOnce

      it 'updates concepts', ->
        Coreon.Models.Search::fetch.yieldsTo 'success', @search,
          hits: [
            score: 1.56
            result:
              id: '1234'
              properties: [ key: 'label', value: 'poet' ]
          ]
        @search.fetch()
        Coreon.Models.Concept.upsert.should.have.been.calledOnce
        Coreon.Models.Concept.upsert.should.have.been.calledWith
          id: '1234'
          properties: [ key: 'label', value: 'poet' ]

      it 'updates current hits', ->
        result = new Backbone.Model
        Coreon.Models.Concept.upsert.withArgs(id: '1234').returns result
        Coreon.Models.Search::fetch.yieldsTo 'success', @search,
          hits: [ score: 1.56, result: id: '1234' ]
        @search.fetch()
        hits = Coreon.Collections.Hits.collection()
        hits.should.have.length 1
        hits.at(0).get('result').should.equal result

  describe '#results()', ->

    beforeEach ->
      @concept1 = new Backbone.Model
      @concept2 = new Backbone.Model
      hits = new Backbone.Collection [
        { score: 1.7, result: @concept1 }
        { score: 1.1, result: @concept2 }
      ]
      sinon.stub Coreon.Collections.Hits, 'collection', -> hits

    afterEach ->
      Coreon.Collections.Hits.collection.restore()

    it 'delegates to hits collection', ->
      expect( @search.results() ).to.eql [ @concept1, @concept2 ]
