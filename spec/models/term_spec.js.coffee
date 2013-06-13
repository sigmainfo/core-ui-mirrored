#= require spec_helper
#= require models/term

describe "Coreon.Models.Term", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @model = new Coreon.Models.Term
  
  afterEach ->
    I18n.t.restore()

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  context "defaults", ->

    it "has an empty set of properties", ->
      @model.get("properties").should.eql []

    it "has an empty value attribure", ->
      @model.get("value").should.eql ""

    it "has an empty lang attribure", ->
      @model.get("lang").should.eql ""

    it "has an empty concept_id attribure", ->
      @model.get("lang").should.eql ""

  describe "urlRoot()", ->
    
    it "is constructed from concept id", ->
      @model.set "concept_id", "4567asdf"
      @model.urlRoot().should.equal "/concepts/4567asdf/terms"

  describe "toJSON()", ->
    
    it "wraps term", ->
      @model.set "value", "foo", silent: true
      @model.toJSON().should.have.deep.property "term.value", "foo"
      
    it "skips concept_id", ->
      @model.toJSON().term.should.not.have.property "concept_id"

  describe "properties()", ->
    
    it "syncs with attr", ->
      @model.set "properties", [key: "label"]
      @model.properties().at(0).should.be.an.instanceof Coreon.Models.Property
      @model.properties().at(0).get("key").should.equal "label"

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.set {
        _id: "abcd1234"
        author: "Nobody"
        properties : [ "foo", "bar" ]
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"

  describe "propertiesByKey()", ->

    it "returns empty hash when empty", ->
      @model.properties = -> models: []
      @model.propertiesByKey().should.eql {}

    it "returns properties grouped by key", ->
      prop1 = new Backbone.Model key: "label"
      prop2 = new Backbone.Model key: "definition"
      prop3 = new Backbone.Model key: "definition"
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      @model.propertiesByKey().should.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]

  describe "save()", ->
    
    beforeEach ->
      Coreon.application = sync: (method, model, options = {}) -> 
        model.id = "1234"
        options.success?()
      @model.message = sinon.spy()

    afterEach ->
      Coreon.application = null

    it "creates message on first save", ->
      I18n.t.withArgs("term.created", value: "high hat").returns 'Successfully created term "high hat"'
      @model.save "value", "high hat"
      @model.message.should.have.been.calledOnce
      @model.message.should.have.been.calledWith 'Successfully created term "high hat"'

    it "creates message on update", ->
      I18n.t.withArgs("term.saved", value: "high hat").returns 'Successfully saved term "high hat"'
      @model.isNew = -> false
      @model.save "value", "high hat"
      @model.message.should.have.been.calledOnce
      @model.message.should.have.been.calledWith 'Successfully saved term "high hat"'

    ## depricated because the term model now sends a message on update
    #it "only creates message on new models", ->
    #  @model.isNew = -> false
    #  @model.save "value", "high hat"
    #  @model.message.should.not.have.been.called

    it "triggers custom event", ->
      spy = sinon.spy()
      @model.on "create", spy
      @model.save "value", "high hat"
      @model.save "value", "beaver hat"
      spy.should.have.been.calledOnce
      spy.should.have.been.calledWith @model, @model.id

  describe "errors()", ->

    it "collects remote validation errors", ->
      @model.trigger "error", @model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      @model.errors().should.eql
        foo: ["must be bar"]

  describe "onDestroy()", ->

    beforeEach ->
      @model.message = sinon.spy()

    it "is triggered when model was destroyed", ->
      @model.onDestroy = sinon.spy()
      @model.initialize()
      @model.trigger "destroy"
      @model.onDestroy.should.have.been.calledOnce
      @model.onDestroy.should.have.been.calledOn @model
  
    it "creates message", ->
      I18n.t.withArgs("term.deleted", value: "high hat").returns 'Successfully deleted term "high hat".'
      @model.set "value", "high hat", silent: true
      @model.onDestroy()
      @model.message.should.have.been.calledOnce
      @model.message.should.have.been.calledWith 'Successfully deleted term "high hat".'
       
  describe "revert()", ->

    it "restores persisted state", ->
      @model.set "value", "hat", silent: true
      @model.trigger "sync"
      @model.set "value", "####", silent: true
      @model.set "value", "****", silent: true
      @model.revert()
      @model.get("value").should.equal "hat"
      
    it "restores initial state", ->
      @model.set "value", "hat", silent: true
      @model.initialize()
      @model.set "value", "####", silent: true
      @model.set "value", "****", silent: true
      @model.revert()
      @model.get("value").should.equal "hat"
