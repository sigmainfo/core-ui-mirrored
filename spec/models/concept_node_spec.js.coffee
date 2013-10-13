#= require spec_helper
#= require models/concept_node

describe "Coreon.Models.ConceptNode", ->

  beforeEach ->
    @concept = new Backbone.Model id: "123"
    @model = new Coreon.Models.ConceptNode concept: @concept

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  describe "defaults", ->

    it "is not expanded", ->
      @model.get("expanded").should.eql no

    it "is not parent of hit", ->
      @model.get("parent_of_hit").should.eql no

    it "is not loaded", ->
      @model.get("loaded").should.equal yes

  describe "initConcept()", ->

    it "is triggered on initialization", ->
      @model.initConcept = sinon.spy()
      @model.initialize()
      @model.initConcept.should.have.been.calledOnce
      @model.initConcept.should.have.been.calledWith @concept, silent: yes

    it "is triggered on change:concept event ", ->
      @model.initConcept = sinon.spy()
      @model.initialize()
      @model.initConcept.reset()
      @model.trigger "change:concept"
      @model.initConcept.should.have.been.calledOnce

    it "derives id from concept", ->
      @concept.id = "concept_1234"
      @model.initConcept @concept
      @model.id.should.equal "concept_1234"
    
    it "derives loaded state from concept", ->
      @concept.blank = yes
      @model.initConcept @concept
      @model.get("loaded").should.equal no

  describe "get()", ->

    it "returns attr from concept", ->
      @concept.set "foo", "bar", silent: yes
      @model.get("foo").should.equal "bar"

    it "returns attr from node", ->
      @model.set "bar", "baz", silent: yes
      @model.get("bar").should.equal "baz"

    it "prefers attr from node", ->
      @concept.set "foo", "bar", silent: yes
      @model.set "foo", "baz", silent: yes
      @model.get("foo").should.equal "baz"

  describe "handleConceptEvent()", ->

    it "is triggered on concept events", ->
      @model.handleConceptEvent = sinon.spy()
      @model.initConcept @concept
      @concept.trigger "foo", @concept, silent: yes
      @model.handleConceptEvent.should.have.been.calledOnce
      @model.handleConceptEvent.should.have.been.calledWith "foo", @concept

    it "triggers event when concept changes", ->
      spy = sinon.spy()
      @model.on "change", spy
      @model.on "change:foo", spy
      @model.handleConceptEvent "change:foo", @concept, "bar", internal: yes
      @model.handleConceptEvent "change", @concept, internal: yes
      spy.should.have.been.calledTwice
      spy.firstCall.should.have.been.calledWith @model, "bar", internal: yes
      spy.secondCall.should.have.been.calledWith @model, internal: yes

    it "does not trigger other concept events", ->
      spy = sinon.spy()
      @model.on "all", spy
      @model.handleConceptEvent "nonblank", @concept
      spy.should.not.have.been.called

    it "syncs id with concept", ->
      @concept.id = "abcdef"
      @model.handleConceptEvent "change:id", @concept
      @model.id.should.equal "abcdef"

    it "does not trigger change:id twice", ->
      spy = sinon.spy()
      @model.on "change:id", spy
      @model.handleConceptEvent "change:id", @concept
      spy.should.have.been.calledOnce

    it "changes loaded state when concept is no longer blank", ->
      @model.set "loaded", no, silent: yes
      @model.handleConceptEvent "nonblank", @concept
      @model.get("loaded").should.be.true
