#= require spec_helper
#= require collections/concept_nodes

describe "Coreon.Collections.ConceptNodes", ->

  beforeEach ->
    @collection = new Coreon.Collections.ConceptNodes

  it "is a backbone collection", ->
    @collection.should.be.an.instanceof Backbone.Collection

  it "creates ConceptNode models", ->
    @collection.add id: "node"
    @collection.get("node").should.be.an.instanceof Coreon.Models.ConceptNode

  describe "initialize()", ->
    
    context "connecting to hits", ->

      beforeEach ->
        class Hit extends Backbone.Model
          idAttribute: "id"
        class Hits extends Backbone.Collection
          model: Hit
        @hits = new Hits
        
      
      it "takes Hits collection as an option", ->
        @collection.initialize [], hits: @hits
        @collection.options.should.have.property "hits", @hits
      
      it "fills collection from hits", ->
        @hits.add id: "123"
        @collection.initialize [], hits: @hits
        expect( @collection.get "123" ).to.exist
        
