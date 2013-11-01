#= require spec_helper
#= require collections/hits

describe 'Coreon.Collections.Hits', ->

  beforeEach ->
    @hits = new Coreon.Collections.Hits

  it 'is a Backbone collection', ->
    expect( @hits ).to.be.an.instanceof Backbone.Collection

  it 'uses Hit model', ->
    expect( @hits ).to.have.property 'model', Coreon.Models.Hit

  describe '.collection()', ->

    it 'creates instance', ->
      collection = Coreon.Collections.Hits.collection()
      expect( collection ).to.be.an.instanceof Coreon.Collections.Hits
      expect( collection ).to.have.lengthOf 0

    it 'ensures single instance', ->
      collection = Coreon.Collections.Hits.collection()
      expect( Coreon.Collections.Hits.collection() ).to.equal collection

  describe '#findByResult()', ->

    beforeEach ->
      @result = new Backbone.Model

    it 'returns null when not found', ->
      hit = @hits.findByResult @result
      expect( hit ).to.be.null

    it 'finds hit for result', ->
      @hits.reset [ result: @result ], silent: true
      hit = @hits.findByResult @result
      expect( hit.get 'result' ).to.equal @result

  describe ':update', ->

    it 'is triggered after a reset', ->
      reset = sinon.spy()
      @hits.on "reset", reset
      change = sinon.spy()
      @hits.on "update", change
      options = log: yes
      @hits.reset [], options
      expect( change ).to.have.been.calledOnce
      expect( change ).to.have.been.calledWith @hits, options
      expect( change ).to.have.been.calledAfter reset
      expect( options ).to.have.property 'previousModels'

    it 'is not triggeret when reset is silent', ->
      change = sinon.spy()
      @hits.on "update", change
      @hits.reset [], silent: yes
      expect( change ).to.not.have.been.called
