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

    it "adds subconcept_id to parents", ->
      @collection.reset [ id: "parent" ], silent: true
      @collection.add id: "child", superconcept_ids: [ "parent" ]
      @collection.get("parent").get("subconcept_ids").should.eql [ "child" ]

    it "adds subconcept_id only when missing", ->
      @collection.reset [ id: "parent", subconcept_ids: [ "child" ] ], silent: true
      @collection.add id: "child", superconcept_ids: [ "parent" ]
      @collection.get("parent").get("subconcept_ids").should.eql [ "child" ]

    it "adds superconcept_id to children", ->
      @collection.reset [ id: "child" ], silent: true
      @collection.add id: "parent", subconcept_ids: [ "child" ]
      @collection.get("child").get("superconcept_ids").should.eql [ "parent" ]

    it "adds superconcept_id only when missing", ->
      @collection.reset [ id: "child", superconcept_ids: [ "parent" ] ], silent: true
      @collection.add id: "parent", subconcept_ids: [ "child" ]
      @collection.get("child").get("superconcept_ids").should.eql [ "parent" ]

    it "does not handle unknown ids", ->
      @collection.reset [], silent: true
      expect( =>
        @collection.add id: "123", superconcept_ids: [ "parent" ], subconcept_ids: [ "child" ]
      ).to.not.throw Error

    it "does not trigger change events", ->
      @collection.reset [ id: "parent" ], silent: true
      spy = @spy()
      @collection.on "change", spy
      @collection.add id: "child", superconcept_ids: [ "parent" ], subconcept_ids: [ "child" ]
      spy.should.not.have.been.called

  describe "when concept is removed", ->

    it "removes itself from parents", ->
      @collection.reset [
        { id: "parent", subconcept_ids: [ "child" ] }
        { id: "child", superconcept_ids: [ "parent" ] }
      ], silent: true
      @collection.remove "child"
      @collection.get("parent").get("subconcept_ids").should.be.empty

    it "removes itself from children", ->
      @collection.reset [
        { id: "parent", subconcept_ids: [ "child" ] }
        { id: "child", superconcept_ids: [ "parent" ] }
      ], silent: true
      @collection.remove "parent"
      @collection.get("child").get("superconcept_ids").should.be.empty

    it "does not handle unknown ids", ->
      @collection.reset [
        { id: "123", superconcept_ids: [ "parent" ], subconcept_ids: [ "child" ] }
      ], silent: true
      expect( =>
        @collection.remove "123"
      ).to.not.throw Error

    it "does not trigger change events", ->
      @collection.reset [
        { id: "123", superconcept_ids: [ "parent" ], subconcept_ids: [ "child" ] }
        { id: "parent", subconcept_ids: [ "123" ] }
        { id: "child", superconcept_ids: [ "123" ] }
      ], silent: true
      spy = @spy()
      @collection.on "change", spy
      @collection.remove "123"
      spy.should.not.have.been.called

  describe "when superconcept_ids change", ->

    it "removes itself from deprecated parents", ->
      @collection.reset [
        { id: "parent", subconcept_ids: [ "child" ] }
        { id: "child", superconcept_ids: [ "parent" ] }
      ], silent: true
      @collection.get("child").set "superconcept_ids", []
      @collection.get("parent").get("subconcept_ids").should.be.empty

    it "adds itself to new parents", ->
      @collection.reset [
        { id: "parent", subconcept_ids: [] }
        { id: "child", superconcept_ids: [] }
      ], silent: true
      @collection.get("child").set "superconcept_ids", [ "parent" ]
      @collection.get("parent").get("subconcept_ids").should.eql [ "child" ]

    it "adds itself to new parents only when missing", ->
      @collection.reset [
        { id: "parent", subconcept_ids: [ "child" ] }
        { id: "child", superconcept_ids: [] }
      ], silent: true
      @collection.get("child").set "superconcept_ids", [ "parent" ]
      @collection.get("parent").get("subconcept_ids").should.eql [ "child" ]

    it "does not handle unknown ids", ->
      @collection.reset [
        { id: "123", superconcept_ids: [ "parent" ], subconcept_ids: [ "child" ] }
      ], silent: true
      @collection.get("123").set
        superconcept_ids: [ "foo" ]
        subconcept_ids: [ "bar" ]

    it "does not trigger change events", ->
      @collection.reset [
        { id: "123", superconcept_ids: [ "parent" ], subconcept_ids: [ "child" ] }
        { id: "parent", subconcept_ids: [ "123" ] }
        { id: "child", superconcept_ids: [ "123" ] }
        { id: "parent2" }
        { id: "child2" }
      ], silent: true
      spy = @spy()
      @collection.on "change", spy
      @collection.get("123").set
        superconcept_ids: [ "parent2" ]
        subconcept_ids: [ "child2" ]
      spy.should.have.been.calledOnce

  describe "when subconcept_ids change", ->

    it "removes itself from deprecated children", ->
      @collection.reset [
        { id: "child", superconcept_ids: [ "parent" ] }
        { id: "parent", subconcept_ids: [ "child" ] }
      ], silent: true
      @collection.get("parent").set "subconcept_ids", []
      @collection.get("child").get("superconcept_ids").should.be.empty

    it "adds itself to new children", ->
      @collection.reset [
        { id: "child", superconcept_ids: [] }
        { id: "parent", subconcept_ids: [] }
      ], silent: true
      @collection.get("parent").set "subconcept_ids", [ "child" ]
      @collection.get("child").get("superconcept_ids").should.eql [ "parent" ]

    it "adds itself to new children only when missing", ->
      @collection.reset [
        { id: "child", superconcept_ids: [ "parent" ] }
        { id: "parent", subconcept_ids: [] }
      ], silent: true
      @collection.get("parent").set "subconcept_ids", [ "child" ]
      @collection.get("child").get("superconcept_ids").should.eql [ "parent" ]

    it "does not handle unknown ids", ->
      @collection.reset [
        { id: "123", subconcept_ids: [ "child" ], superconcept_ids: [ "parent" ] }
      ], silent: true
      @collection.get("123").set
        subconcept_ids: [ "foo" ]
        superconcept_ids: [ "bar" ]

    it "does not trigger change events", ->
      @collection.reset [
        { id: "123", subconcept_ids: [ "child" ], superconcept_ids: [ "parent" ] }
        { id: "child", superconcept_ids: [ "123" ] }
        { id: "parent", subconcept_ids: [ "123" ] }
        { id: "child2" }
        { id: "parent2" }
      ], silent: true
      spy = @spy()
      @collection.on "change", spy
      @collection.get("123").set
        subconcept_ids: [ "child2" ]
        superconcept_ids: [ "parent2" ]
      spy.should.have.been.calledOnce
