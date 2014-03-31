#= require spec_helper
#= require modules/helpers
#= require modules/properties_by_key

describe 'Coreon.Modules.PropertiesByKey', ->

  before -> class Coreon.Models.MyModel extends Backbone.Model
    Coreon.Modules.include @, Coreon.Modules.PropertiesByKey

  after ->
    delete Coreon.Models.MyModel

  beforeEach ->
    @model = new Coreon.Models.MyModel

  describe '#propertiesByKey()', ->

    it 'returns empty hash when empty', ->
      @model.properties = -> models: []
      expect( @model.propertiesByKey() ).to.eql {}

    it 'returns properties grouped by key', ->
      prop1 = new Backbone.Model key: 'label'
      prop2 = new Backbone.Model key: 'definition'
      prop3 = new Backbone.Model key: 'definition'
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      expect( @model.propertiesByKey() ).to.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]

    it 'skips hidden properties', ->
      @model.hiddenProperties = ['precedence']
      prop1 = new Backbone.Model key: 'label'
      prop2 = new Backbone.Model key: 'precedence'
      @model.properties = -> models: [ prop1, prop2 ]
      expect( @model.propertiesByKey() ).to.eql
        label: [ prop1 ]

  describe '#propertiesByKeyAndLang()', ->

    it 'returns empty hash when empty', ->
      @model.properties = -> models: []
      expect( @model.propertiesByKeyAndLang() ).to.eql {}

    it 'returns properties grouped by key', ->
      prop1 = new Backbone.Model key: 'label'
      prop2 = new Backbone.Model key: 'definition'
      prop3 = new Backbone.Model key: 'definition', lang: 'fr'
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      expect( @model.propertiesByKeyAndLang() ).to.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]

    context "with source language set to French", ->

      beforeEach ->
        Coreon.application =
          repositorySettings: () ->
            get: (arg)->
              return 'fr' if arg == 'sourceLanguage'
            on: ->

      afterEach ->
        delete Coreon.application

      it 'returns properties grouped by key, French first', ->
        prop1 = new Backbone.Model key: 'label'
        prop2 = new Backbone.Model key: 'definition'
        prop3 = new Backbone.Model key: 'definition', lang: 'fr'
        prop4 = new Backbone.Model key: 'label', lang: 'de'
        @model.properties = -> models: [ prop1, prop2, prop3, prop4 ]
        expect( @model.propertiesByKeyAndLang() ).to.eql
          label: [ prop1, prop4 ]
          definition: [ prop3, prop2 ]

    context "with target language set to German", ->

      beforeEach ->
        Coreon.application =
          repositorySettings: () ->
            get: (arg)->
              return 'de' if arg == 'targetLanguage'
            on: ->

      afterEach ->
        delete Coreon.application

      it 'returns properties grouped by key, German first', ->
        prop1 = new Backbone.Model key: 'label'
        prop2 = new Backbone.Model key: 'definition'
        prop3 = new Backbone.Model key: 'definition', lang: 'fr'
        prop4 = new Backbone.Model key: 'label', lang: 'de'
        @model.properties = -> models: [ prop1, prop2, prop3, prop4 ]
        expect( @model.propertiesByKeyAndLang() ).to.eql
          label: [ prop4, prop1 ]
          definition: [ prop2, prop3 ]

    context "with source language set to French and target language set to German", ->

      beforeEach ->
        Coreon.application =
          repositorySettings: () ->
            get: (arg)->
              return 'fr' if arg == 'sourceLanguage'
              return 'de' if arg == 'targetLanguage'
            on: ->

      afterEach ->
        delete Coreon.application

      it 'returns properties grouped by key, French first, German second', ->
        prop1 = new Backbone.Model key: 'label'
        prop2 = new Backbone.Model key: 'definition'
        prop3 = new Backbone.Model key: 'definition', lang: 'de'
        prop4 = new Backbone.Model key: 'definition', lang: 'fr'
        @model.properties = -> models: [ prop1, prop2, prop3, prop4 ]
        expect( @model.propertiesByKeyAndLang() ).to.eql
          label: [ prop1 ]
          definition: [ prop4, prop3, prop2 ]
