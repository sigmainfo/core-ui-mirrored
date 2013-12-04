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

    it 'creates instance', ->
      collection = Coreon.Collections.Terms.collection()
      expect( collection ).to.be.an.instanceof Coreon.Collections.Terms
      expect( collection ).to.have.lengthOf 0

    it 'ensures single instance', ->
      collection = Coreon.Collections.Terms.collection()
      expect( Coreon.Collections.Terms.collection() ).to.equal collection

  describe '#comparator()', ->

    it 'sorts by value', ->
      @collection.reset [
        { lang: 'en', value: 'Billiards' }
        { lang: 'de', value: 'Queue'     }
        { lang: 'de', value: 'Cue'       }
      ]
      values = @collection.models.map (term) ->
        term.get 'value'
      expect( values[0] ).to.eql 'Billiards'
      expect( values[1] ).to.eql 'Cue'
      expect( values[2] ).to.eql 'Queue'

  describe "#toJSON()", ->

    it "strips wrapping objects from terms", ->
      @collection.reset [ value: "high hat", lang: "de", properties: [] ]
      @collection.toJSON().should.eql [ value: "high hat", lang: "de", properties: [] ]
