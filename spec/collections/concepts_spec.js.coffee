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

  describe "when concept was removed", ->

    it "removes parent concepts", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [ "parent" ] }
        { _id: "other" }
      ], silent: on
      @collection.remove "child"
      expect( @collection.get "parent" ).to.not.exist
      expect( @collection.get "other" ).to.exist

    it "removes child concepts", ->
      @collection.reset [
        { _id: "parent", sub_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [ "parent" ] }
        { _id: "other" }
      ], silent: on
      @collection.remove "parent"
      expect( @collection.get "child" ).to.not.exist
      expect( @collection.get "other" ).to.exist

    it "does not remove parent of parent", ->
      @collection.reset [
        { _id: "parent_of_parent", sub_concept_ids: [ "parent" ] }
        { _id: "parent", sub_concept_ids: [ "child" ], super_concept_ids: [ "parent_of_parent"] }
        { _id: "child", super_concept_ids: [ "parent" ] }
      ], silent: on
      @collection.remove "child"
      expect( @collection.get "parent_of_parent" ).to.exist
      
    it "does not remove child of child", ->
      @collection.reset [
        { _id: "child_of_child", super_concept_ids: [ "child" ] }
        { _id: "child", super_concept_ids: [ "parent" ], sub_concept_ids: [ "child_of_child"] }
        { _id: "parent", sub_concept_ids: [ "child" ] }
      ], silent: on
      @collection.remove "parent"
      expect( @collection.get "child_of_child" ).to.exist
    

  #TODO: update on change
  #TODO: update super_concept_ids
      
