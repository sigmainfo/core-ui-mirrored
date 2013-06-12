#= require spec_helper
#= require modules/helpers
#= require modules/persisted_attributes

describe "Coreon.Modules.PersistedAttributes", ->

  before ->
    class Coreon.Models.ModelWithPersistedAttributes extends Backbone.Model
      Coreon.Modules.include @, Coreon.Modules.PersistedAttributes

      initialize: ->
        @persistedAttributesOn()

  after ->
    delete Coreon.Models.ModelWithPersistedAttributes

  beforeEach ->
    @model = new Coreon.Models.ModelWithPersistedAttributes

  describe "persistedAttributes()", ->
  
    it "returns empty hash when new", ->
      @model.persistedAttributes().should.eql {}
      @model.persistedAttributes().should.not.be.an.instanceof Array

    it "returns synced state of attributes hash", ->
      @model.set foo: "bar"
      @model.trigger "sync"
      @model.set "foo", "baz"
      @model.set "baz", "bar"
      @model.persistedAttributes().should.eql foo: "bar"

    it "returns copy of attributes hash", ->
      @model.trigger "sync"
      @model.persistedAttributes().should.not.equal @model.attributes
      

  describe "isPersisted()", ->

    it "returns false for non-existent attribute", ->
      @model.isPersisted("foo").should.be.false

    it "returns true for unchanged attribute"

    it "returns false for changed attribute"

  describe "reset()", ->

    it "restores persisted model state"
     
    it "triggers events"
      
