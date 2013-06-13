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

    it "returns true for unchanged attribute", ->
      @model.set "foo", "bar"
      @model.trigger "sync"
      @model.isPersisted("foo").should.be.true

    it "returns false for changed attribute", ->
      @model.set "foo", "bar"
      @model.trigger "sync"
      @model.set "foo", "baz"
      @model.isPersisted("foo").should.be.false

  describe "restore()", ->

    beforeEach ->
      @model.set "foo", "bar", silent: true
      @model.set {
        foo: "bar"
        bar: "baz"
      }, silent: on
      @model.trigger "sync"

    it "can be chained", ->
      @model.restore().should.equal @model 

    it "restores persisted model state", ->
      @model.set { foo: "baz", poo: "foo" }, silent: true
      @model.restore()
      @model.attributes.should.eql foo: "bar", bar: "baz"
     
    it "triggers change event", ->
      spy = sinon.spy()
      @model.set "foo", "baz", silent: true
      @model.on "change", spy
      @model.restore areYouSure: yes
      spy.should.have.been.calledOnce
      spy.should.have.been.calledWith @model, areYouSure: yes

    it "triggers change events for restored attrs", ->
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      @model.set { foo: "baz", bar: "poo" }, silent: true
      @model.on "change:foo", spy1
      @model.on "change:bar", spy2
      @model.restore areYouSure: yes
      spy1.should.have.been.calledOnce
      spy1.should.have.been.calledWith @model, "bar", areYouSure: yes
      spy2.should.have.been.calledOnce
      spy2.should.have.been.calledWith @model, "baz", areYouSure: yes

    it "silences events", ->
      spy = sinon.spy()
      @model.set foo: "baz", bar: "poo"
      @model.on "all", spy
      @model.restore silent: on
      spy.should.not.have.been.called
