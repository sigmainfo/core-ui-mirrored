#= require spec_helper
#= require modules/helpers
#= require modules/properties_by_key

describe "Coreon.Modules.PropertiesByKey", ->

  before -> class Coreon.Models.MyModel extends Backbone.Model
    Coreon.Modules.include @, Coreon.Modules.PropertiesByKey

  after ->
    delete Coreon.Models.MyModel

  beforeEach ->
    @model = new Coreon.Models.MyModel

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
