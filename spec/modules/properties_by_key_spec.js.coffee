#= require spec_helper
#= require modules/helpers
#= require modules/properties_by_key

describe 'Coreon.Modules.PropertiesByKey', ->

  model = null

  before -> class Coreon.Models.MyModel extends Backbone.Model
    Coreon.Modules.include @, Coreon.Modules.PropertiesByKey

  after ->
    delete Coreon.Models.MyModel

  beforeEach ->
    model = new Coreon.Models.MyModel

  describe '#propertiesByKey()', ->

    context 'unordered', ->

      it 'returns empty hash when empty', ->
        model.properties = -> models: []
        expect( model.propertiesByKey() ).to.eql {}

      it 'returns properties grouped by key', ->
        prop1 = new Backbone.Model key: 'label'
        prop2 = new Backbone.Model key: 'definition'
        prop3 = new Backbone.Model key: 'definition'
        model.properties = -> models: [ prop1, prop2, prop3 ]
        expect( model.propertiesByKey() ).to.eql
          label: [ prop1 ]
          definition: [ prop2, prop3 ]

      it 'skips hidden properties', ->
        model.hiddenProperties = ['precedence']
        prop1 = new Backbone.Model key: 'label'
        prop2 = new Backbone.Model key: 'precedence'
        model.properties = -> models: [ prop1, prop2 ]
        expect( model.propertiesByKey() ).to.eql
          label: [ prop1 ]

    context 'ordered by language precedence', ->

      properties = null

      beforeEach ->
        properties = new Backbone.Collection
        model.properties = -> properties

      it 'returns empty set by default', ->
        properties.reset [], silent: yes
        result = model.propertiesByKey precedence: ['en', 'de']
        expect(result).to.eql []

      it 'groups properties by key', ->
        properties.reset [
          {key: 'source', value: 'Wikipedia'}
          {key: 'source', value: 'Internet'}
          {key: 'lenoch code', value: 'MA'}
        ]
        [property1, property2, property3] = properties.models
        result = model.propertiesByKey precedence: ['en', 'de']
        expect(result).to.have.lengthOf 2
        group1 = result[0]
        expect(group1).to.have.property 'key', 'source'
        expect(group1.properties).to.eql [property1, property2]
        group2 = result[1]
        expect(group2).to.have.property 'key', 'lenoch code'
        expect(group2.properties).to.eql [property3]

      it 'orders properties by given language precedence', ->
        properties.reset [
          {key: 'source', lang: 'de', value: 'Internetz'}
          {key: 'source', lang: 'en', value: 'Internet'}
          {key: 'source', lang: 'de', value: 'Netz'}
        ]
        [property1, property2, property3] = properties.models
        result = model.propertiesByKey precedence: ['en', 'de']
        group = result[0].properties
        expect(group).to.eql [property2, property1, property3]

      it 'puts unknown langs at the end', ->
        properties.reset [
          {key: 'source', lang: 'de', value: 'Internetz'}
          {key: 'source', lang: 'fr', value: 'www'}
          {key: 'source', lang: 'en', value: 'internet'}
        ]
        [property1, property2, property3] = properties.models
        result = model.propertiesByKey precedence: ['en', 'de']
        group = result[0].properties
        expect(group).to.eql [property3, property1, property2]

      it 'skips hidden properties', ->
        model.hiddenProperties = ['precedence']
        prop1 = new Backbone.Model key: 'label'
        prop2 = new Backbone.Model key: 'precedence'
        properties.reset [
          {key: 'label'}
          {key: 'precedence'}
          {key: 'precedence'}
        ]
        [property1, property2, property3] = properties.models
        result = model.propertiesByKey precedence: ['en', 'de']
        expect(result).to.have.lengthOf 1
        expect(result[0]).to.have.property 'key', 'label'

  describe '#propertiesByKeyAndLang()', ->

    it 'returns empty hash when empty', ->
      model.properties = -> models: []
      expect( model.propertiesByKeyAndLang() ).to.eql {}

    it 'returns properties grouped by key', ->
      prop1 = new Backbone.Model key: 'label'
      prop2 = new Backbone.Model key: 'definition'
      prop3 = new Backbone.Model key: 'definition', lang: 'fr'
      model.properties = -> models: [ prop1, prop2, prop3 ]
      expect( model.propertiesByKeyAndLang() ).to.eql
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
        model.properties = -> models: [ prop1, prop2, prop3, prop4 ]
        expect( model.propertiesByKeyAndLang() ).to.eql
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
        model.properties = -> models: [ prop1, prop2, prop3, prop4 ]
        expect( model.propertiesByKeyAndLang() ).to.eql
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
        model.properties = -> models: [ prop1, prop2, prop3, prop4 ]
        expect( model.propertiesByKeyAndLang() ).to.eql
          label: [ prop1 ]
          definition: [ prop4, prop3, prop2 ]
