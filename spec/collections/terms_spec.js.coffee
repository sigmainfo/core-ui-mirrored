#= require spec_helper
#= require collections/terms

describe "Coreon.Collections.Terms", ->

  beforeEach ->
    @collection = new Coreon.Collections.Terms

  it "is a backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "creates Term models", ->
    @collection.add id: "term"
    @collection.get("term").should.be.an.instanceof Coreon.Models.Term

  describe '.collection()', ->

    beforeEach ->
      @hits = new Backbone.Collection
      sinon.stub Coreon.Collections.Hits, 'collection', => @hits
      @collection = Coreon.Collections.Terms.collection()

    afterEach ->
      Coreon.Collections.Terms._collection = null
      Coreon.Collections.Hits.collection.restore()

    it 'creates instance', ->
      expect( @collection ).to.be.an.instanceof Coreon.Collections.Terms
      expect( @collection ).to.have.lengthOf 0

    it 'ensures single instance', ->
      expect( Coreon.Collections.Terms.collection() ).to.equal @collection

    it 'updates itself from hits', ->
      @collection.reset [
        value: 'old', lang: 'en'
      ], silent: yes

      concept1 = new Backbone.Model
      concept1.terms = -> new Backbone.Collection [
        { value: 'Billiard' , lang: 'de' }
        { value: 'billiards', lang: 'en' }
      ]
      concept2 = new Backbone.Model
      concept2.terms = -> new Backbone.Collection [
        { value: 'Queue', lang: 'de' }
      ]
      concept3 = new Backbone.Model
      concept3.terms = -> new Backbone.Collection [ ]

      @hits.reset [
        { result: concept1 }
        { result: concept2 }
        { result: concept3 }
      ], silent: yes
      @hits.trigger 'update'
      expect( @collection ).to.have.lengthOf 3
      term1 = @collection.findWhere { value: 'Billiard' , lang: 'de' }
      expect( term1 ).to.exist
      term2 = @collection.findWhere { value: 'billiards', lang: 'en' }
      expect( term2 ).to.exist
      term3 = @collection.findWhere { value: 'Queue'    , lang: 'de' }
      expect( term3 ).to.exist

    it 'updates itself when terms on hit change', ->
      concept = new Backbone.Model
      concept.terms = -> new Backbone.Collection [ { value: 'Billiard' , lang: 'de' } ]
      @hits.reset [ result: concept ], silent: yes
      @hits.trigger 'update'
      concept.terms = -> new Backbone.Collection [ { value: 'Foo' , lang: 'de' } ]
      concept.trigger 'change:terms'
      expect( @collection ).to.have.lengthOf 1
      term = @collection.at 0
      expect( term.get 'value' ).to.equal 'Foo'

  describe '#comparator()', ->

    it 'sorts by value', ->
      @collection.reset [
        { lang: 'en', value: 'Billiards' }
        { lang: 'de', value: 'Queue'     }
        { lang: 'en', value: 'Cue'       }
      ]
      values = @collection.pluck 'value'
      expect( values[0] ).to.eql 'Billiards'
      expect( values[1] ).to.eql 'Cue'
      expect( values[2] ).to.eql 'Queue'

  describe '#lang()', ->

    it 'filters terms by given lang', ->
      @collection.reset [
        { lang: 'en', value: 'Billiards' }
        { lang: 'de', value: 'Queue'     }
        { lang: 'en', value: 'Cue'       }
      ]
      en = @collection.lang 'en'
      values = en.map (term) -> term.get 'value'
      expect( values ).to.contain 'Billiards', 'Cue'
      expect( values ).to.not.contain 'Queue'

  describe "#toJSON()", ->

    it "strips wrapping objects from terms", ->
      @collection.reset [ value: "high hat", lang: "de", properties: [] ]
      @collection.toJSON().should.eql [ value: "high hat", lang: "de", properties: [] ]
