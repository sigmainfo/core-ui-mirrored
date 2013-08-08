#= require spec_helper
#= require models/concept

describe "Coreon.Collections.Concepts", ->
  
  beforeEach ->
    @collection = new Coreon.Collections.Concepts

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "uses Concept model", ->
    @collection.model.should.equal Coreon.Models.Concept

  describe "when concept was added", ->

    it "adds sub_concept_id to parent", ->
      @collection.reset [ _id: "parent" ], silent: true
      @collection.add _id: "child", super_concept_ids: [ "parent" ]
      @collection.get("parent").get("sub_concept_ids").should.eql [ "child" ]

    it "adds sub_concept_id only when missing", ->
      @collection.reset [ _id: "parent", sub_concept_ids: [ "child" ] ], silent: true
      @collection.add _id: "child", super_concept_ids: [ "parent" ]
      @collection.get("parent").get("sub_concept_ids").should.eql [ "child" ]

    it "does not handle unknown super_concept_ids", ->
      @collection.reset [], silent: true
      expect( =>
        @collection.add _id: "child", super_concept_ids: [ "parent" ]
      ).to.not.throw Error

  #TODO: update on remove, change
  #TODO: update super_concept_ids
      
