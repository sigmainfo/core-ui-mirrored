#= require spec_helper
#= require modules/helpers
#= require modules/embeds_many

describe "Coreon.Modules.EmbedsMany", ->

  before ->
    class Coreon.Models.MySubModel extends Backbone.Model

    class Coreon.Collections.MySubModels extends Backbone.Collection
      model: Coreon.Models.MySubModel
      
    class Coreon.Models.MyModel extends Backbone.Model
      Coreon.Modules.extend @, Coreon.Modules.EmbedsMany
      @embedsMany "submodels"

  after ->
    delete Coreon.Models.MyNestedModel
    delete Coreon.Collections.MyNestedCollection
    delete Coreon.Models.MyModel

  beforeEach ->
    @model = new Coreon.Models.MyModel

  describe "submodels()", ->

    context "with default configuration", ->
              
      beforeEach ->
        Coreon.Models.MyModel.embedsMany "submodels"

      it "returns empty collection", ->
        @model.submodels().should.be.an.instanceof Backbone.Collection
        @model.submodels().should.have.lengthOf 0

      it "triggers change events", ->
        spy = sinon.spy()
        @model.on "change:submodels", spy
        @model.submodels().add foo: "bar"
        spy.should.have.been.calledOnce

    context "with custom configuration", ->
      
      it "uses provided collection type", ->
        Coreon.Models.MyModel.embedsMany "submodels", collection: Coreon.Collections.MySubModels
        @model.submodels().should.be.an.instanceof Coreon.Collections.MySubModels

      it "uses provided model type", ->
        Coreon.Models.MyModel.embedsMany "submodels", model: Coreon.Models.MySubModel
        @model.set "submodels", [foo: "bar"]
        @model.submodels().at(0).should.be.an.instanceof Coreon.Models.MySubModel
        

  describe "set()", ->
  
    it "populates relation", ->
      @model.set "submodels", [foo: "bar"], silent: true
      @model.submodels().should.have.lengthOf 1
      @model.submodels().at(0).get("foo").should.equal "bar"
        
    it "syncs relation", ->
      @model.submodels()
      @model.set "submodels", [foo: "bar"]
      @model.submodels().should.have.lengthOf 1
      @model.submodels().at(0).get("foo").should.equal "bar"

  describe "get()", ->

    it "syncs attr when relation is reset", ->
      @model.submodels().reset foo: "bar"
      @model.get("submodels").should.eql [foo: "bar"]

    it "syncs attr when submodel is added", ->
      @model.submodels().add foo: "bar"
      @model.get("submodels").should.eql [foo: "bar"]
  
    it "syncs attr when submodel is removed", ->
      @model.set "submodels", [_id: "bar"], silent: true
      @model.submodels().remove "bar"
      @model.get("submodels").should.eql []

    it "syncs attr when submodel changes", ->
      @model.set "submodels", [foo: "bar"], silent: true
      @model.submodels().at(0).set "foo", "baz"
      @model.get("submodels").should.eql [foo: "baz"]

    it "syncs attr when submodel was synced", ->
      @model.submodels().reset foo: "bar"
      submodel = @model.submodels().at 0
      submodel.set "foo", "baz", silent: true
      submodel.trigger "sync"
      @model.get("submodels").should.eql [foo: "baz"]
      
    it "syncs attr when relation is sorted", ->
      @model.set "submodels", [{pos: 3}, {pos: 1}], silent: true
      @model.submodels().comparator = (model) -> model.get "pos"
      @model.submodels().sort()
      @model.get("submodels").should.eql [{pos: 1}, {pos: 3}]
