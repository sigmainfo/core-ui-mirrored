#= require spec_helper
#= require collections/hits

describe "Coreon.Collections.Hits", ->

  beforeEach ->
    @hits = new Coreon.Collections.Hits
    @hit  = new Coreon.Models.Hit id: "799"

  it "is a Backbone collection", ->
    @hits.should.be.an.instanceof Backbone.Collection

  it "uses Hit model", ->
    @hits.model.should.equal Coreon.Models.Hit

  describe "update()", ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, "find"
      @concept = new Coreon.Models.Concept _id: "799"
      Coreon.Models.Concept.find.withArgs("799").returns @concept
      @spy = sinon.spy()

    afterEach ->
      Coreon.Models.Concept.find.restore()
      
    it "adds missing", ->
      @hit.on "add", @spy
      @hits.update [ @hit ]
      @spy.should.have.been.calledOnce
      @hits.models.should.eql [ @hit ]

    it "removes dropped", ->
      @hits.add [ @hit ], silent: true
      @hit.on "remove", @spy
      @hits.update []
      @spy.should.have.been.calledOnce
      @hits.models.should.eql []

    it "keeps existing", ->
      @hits.add [ @hit ], silent: true
      @hit.on "add remove", @spy
      @hits.update [ @hit ]
      @spy.should.not.have.been.called
      @hits.models.should.eql [ @hit ]

    context "hit:update", ->

      it "triggers hit:update on collection", ->
        @hits.on "hit:update", @spy
        @hits.update [ @hit ]
        @spy.should.have.been.calledOnce
        @spy.should.have.been.calledWith @hits, index: 0

      it "does not trigger hit:update when not changed", ->
        @hits.update [ @hit ], silent: true
        @hits.on "hit:update", @spy
        @hits.update [ @hit ]
        @spy.should.not.have.been.called

      it "does not trigger hit:update when silent is true", ->
        @hits.on "hit:add hit:remove hit:update", @spy
        @hits.update [ @hit ], silent: true
        @hits.update [], silent: true
        @spy.should.not.have.been.called

    context "events on related concept", ->

      it "triggers hit:add", ->
        @concept.on "hit:add", @spy
        @hits.update [ @hit ]
        @spy.should.have.been.calledOnce
        @spy.should.have.been.calledWith @hit, @hits, index: 0

      it "triggers hit:remove", ->
        @hits.update [ @hit ], silent: true
        @concept.on "hit:remove", @spy
        @hits.update []
        @spy.should.have.been.calledOnce
        @spy.should.have.been.calledWith @hit, @hits, index: 0
