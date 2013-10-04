#= require spec_helper
#= require models/concept_node

describe "Coreon.Models.ConceptNode", ->

  beforeEach ->
    @concept = new Backbone.Model id: "123"
    @model = new Coreon.Models.ConceptNode
      id: "123"
      concept: @concept

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  describe "defaults", ->

    it "is not expanded", ->
      @model.get("expanded").should.eql no

    it "is not parent of hit", ->
      @model.get("parent_of_hit").should.eql no

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
      

  describe "change", ->

    it "triggers event when concept changes", ->
      spy = sinon.spy()
      @model.on "change", spy
      @model.on "change:foo", spy
      @concept.set "foo", "bar", internal: yes
      spy.should.have.been.calledTwice
      spy.firstCall.should.have.been.calledWith @model, "bar", internal: yes
      spy.secondCall.should.have.been.calledWith @model, internal: yes

    it "does not trigger other concept events", ->
      spy = sinon.spy()
      @model.on "all", spy
      @concept.trigger "ready"
      spy.should.not.have.been.called

    it "syncs id with concept", ->
      @concept.set "id", "abcdef"
      @model.id.should.equal "abcdef"
      

  describe "change:concept", ->

    beforeEach ->
      @concept2 = new Backbone.Model id: "concept_2"
      @model.set "concept", @concept2
    
    it "triggers events of new concept", ->
      spy = sinon.spy()
      @model.on "change", spy
      @model.on "change:foo", spy
      @concept2.set "foo", "bar", internal: yes
      spy.should.have.been.calledTwice
      spy.firstCall.should.have.been.calledWith @model, "bar", internal: yes
      spy.secondCall.should.have.been.calledWith @model, internal: yes

    it "does not trigger events of old concept", ->
      spy = sinon.spy()
      @model.on "change", spy
      @model.on "change:foo", spy
      @concept.set "foo", "bar", internal: yes
      spy.should.not.have.been.called

    it "adopts id from concept", ->
      @model.id.should.equal "concept_2"
