#= require spec_helper
#= require models/concept

describe "Coreon.Collections.Concepts", ->
  
  beforeEach ->
    @collection = new Coreon.Collections.Concepts

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "uses Concept model", ->
    @collection.model.should.equal Coreon.Models.Concept

  describe "when concept is added", ->

    it "adds sub_concept_id to parents", ->
      @collection.reset [ _id: "parent" ], silent: true
      @collection.add _id: "child", super_concept_ids: [ "parent" ]
      @collection.get("parent").get("sub_concept_ids").should.eql [ "child" ]

    it "adds sub_concept_id only when missing", ->
      @collection.reset [ _id: "parent", sub_concept_ids: [ "child" ] ], silent: true
      @collection.add _id: "child", super_concept_ids: [ "parent" ]
      @collection.get("parent").get("sub_concept_ids").should.eql [ "child" ]

    it "adds super_concept_id to children", ->
      @collection.reset [ _id: "child" ], silent: true
      @collection.add _id: "parent", sub_concept_ids: [ "child" ]
      @collection.get("child").get("super_concept_ids").should.eql [ "parent" ]

    it "adds super_concept_id only when missing", ->
      @collection.reset [ _id: "child", super_concept_ids: [ "parent" ] ], silent: true
      @collection.add _id: "parent", sub_concept_ids: [ "child" ]
      @collection.get("child").get("super_concept_ids").should.eql [ "parent" ]

    it "does not handle unknown ids", ->
      @collection.reset [], silent: true
      expect( =>
        @collection.add _id: "123", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child" ]
      ).to.not.throw Error

    it "does not trigger change events", ->
      @collection.reset [ _id: "parent" ], silent: true
      spy = sinon.spy()
      @collection.on "change", spy
      @collection.add _id: "child", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child" ]
      spy.should.not.have.been.called

  describe "when concept is removed", ->
    
    it "removes itself from parents", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [ "parent" ] }
      ], silent: true
      @collection.remove "child"
      @collection.get("parent").get("sub_concept_ids").should.be.empty

    it "removes itself from children", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [ "parent" ] }
      ], silent: true
      @collection.remove "parent"
      @collection.get("child").get("super_concept_ids").should.be.empty

    it "does not handle unknown ids", ->
      @collection.reset [
        { _id: "123", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child" ] }
      ], silent: true
      expect( =>
        @collection.remove "123"
      ).to.not.throw Error

    it "does not trigger change events", ->
      @collection.reset [
        { _id: "123", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child" ] }
        { _id: "parent", sub_concept_ids: [ "123" ] }
        { _id: "child", super_concept_ids: [ "123" ] }
      ], silent: true
      spy = sinon.spy()
      @collection.on "change", spy
      @collection.remove "123"
      spy.should.not.have.been.called

  describe "when super_concept_ids change", ->
    
    it "removes itself from deprecated parents", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [ "parent" ] }
      ], silent: true
      @collection.get("child").set "super_concept_ids", []
      @collection.get("parent").get("sub_concept_ids").should.be.empty

    it "adds itself to new parents", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [] }
        { _id: "child", super_concept_ids: [] }
      ], silent: true
      @collection.get("child").set "super_concept_ids", [ "parent" ]
      @collection.get("parent").get("sub_concept_ids").should.eql [ "child" ]

    it "adds itself to new parents only when missing", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [] }
      ], silent: true
      @collection.get("child").set "super_concept_ids", [ "parent" ]
      @collection.get("parent").get("sub_concept_ids").should.eql [ "child" ]

    it "does not handle unknown ids", ->
      @collection.reset [
        { _id: "123", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child" ] }
      ], silent: true
      @collection.get("123").set
        super_concept_ids: [ "foo" ]
        sub_concept_ids: [ "bar" ]
    
    it "does not trigger change events", ->
      @collection.reset [
        { _id: "123", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child" ] }
        { _id: "parent", sub_concept_ids: [ "123" ] }
        { _id: "child", super_concept_ids: [ "123" ] }
        { _id: "parent2" }
        { _id: "child2" }
      ], silent: true
      spy = sinon.spy()
      @collection.on "change", spy
      @collection.get("123").set
        super_concept_ids: [ "parent2" ]
        sub_concept_ids: [ "child2" ]
      spy.should.have.been.calledOnce

  describe "when sub_concept_ids change", ->
    
    it "removes itself from deprecated children", ->
      @collection.reset [
        { _id: "child", super_concept_ids: [ "parent" ] }
        { _id: "parent", sub_concept_ids: [ "child" ] }
      ], silent: true
      @collection.get("parent").set "sub_concept_ids", []
      @collection.get("child").get("super_concept_ids").should.be.empty

    it "adds itself to new children", ->
      @collection.reset [
        { _id: "child", super_concept_ids: [] }
        { _id: "parent", sub_concept_ids: [] }
      ], silent: true
      @collection.get("parent").set "sub_concept_ids", [ "child" ]
      @collection.get("child").get("super_concept_ids").should.eql [ "parent" ]

    it "adds itself to new children only when missing", ->
      @collection.reset [
        { _id: "child", super_concept_ids: [ "parent" ] }
        { _id: "parent", sub_concept_ids: [] }
      ], silent: true
      @collection.get("parent").set "sub_concept_ids", [ "child" ]
      @collection.get("child").get("super_concept_ids").should.eql [ "parent" ]

    it "does not handle unknown ids", ->
      @collection.reset [
        { _id: "123", sub_concept_ids: [ "child" ], super_concept_ids: [ "parent" ] }
      ], silent: true
      @collection.get("123").set
        sub_concept_ids: [ "foo" ]
        super_concept_ids: [ "bar" ]
    
    it "does not trigger change events", ->
      @collection.reset [
        { _id: "123", sub_concept_ids: [ "child" ], super_concept_ids: [ "parent" ] }
        { _id: "child", super_concept_ids: [ "123" ] }
        { _id: "parent", sub_concept_ids: [ "123" ] }
        { _id: "child2" }
        { _id: "parent2" }
      ], silent: true
      spy = sinon.spy()
      @collection.on "change", spy
      @collection.get("123").set
        sub_concept_ids: [ "child2" ]
        super_concept_ids: [ "parent2" ]
      spy.should.have.been.calledOnce
