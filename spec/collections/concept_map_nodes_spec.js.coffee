#= require spec_helper
#= require collections/concept_map_nodes

describe "Coreon.Collections.ConceptMapNode", ->

  beforeEach ->
    @repository = new Backbone.Model
    Coreon.application = repository: => @repository
    @collection = new Coreon.Collections.ConceptMapNodes

  afterEach ->
    delete Coreon.application

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceof Coreon.Collections.ConceptMapNodes

  it "creates ConceptMapNode models", ->
    @collection.reset [ id: "node" ], silent: yes
    @collection.should.have.lengthOf 1
    @collection.at(0).should.be.an.instanceof Coreon.Models.ConceptMapNode

  describe "#build()", ->
      
    it "removes old nodes", ->
      @collection.reset [ id: "node" ], silent: yes
      node = @collection.at(0)
      @collection.build()
      expect( @collection.get node ).to.not.exist

    it "creates root node", ->
      @collection.reset [], silent: yes
      @collection.build()
      root = @collection.at(0)
      expect( root ).to.exist
      expect( root.get "model" ).to.equal @repository
