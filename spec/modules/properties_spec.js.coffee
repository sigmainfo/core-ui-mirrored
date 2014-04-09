#= require spec_helper
#= require modules/helpers
#= require modules/properties

describe 'Coreon.Modules.Properties', ->

  model = null

  before -> class Coreon.Models.ModelWithProperties extends Backbone.Model
    Coreon.Modules.include @, Coreon.Modules.Properties

  after ->
    delete Coreon.Models.ModelWithProperties

  properties = null

  beforeEach ->
    model = new Coreon.Models.ModelWithProperties
    properties = new Backbone.Collection
    model.properties = -> properties

  describe '#visibleProperties()', ->

    it 'filters out hidden properties', ->
      model.hiddenPropertyKeys = ['precedence']
      properties.reset [
        {key: 'precedence'}
        {key: 'description'}
      ], silent: yes
      [prop1, prop2] = properties.models
      visible = model.visibleProperties()
      expect(visible).to.eql [prop2]

  describe '#hasProperties()', ->

    it 'returns false when there are no visible properties', ->
      model.visibleProperties = -> []
      hasProperties = model.hasProperties()
      expect(hasProperties).to.be.false

    it 'returns true when there are any visible properties', ->
      property = new Backbone.Model
      model.visibleProperties = -> [property]
      hasProperties = model.hasProperties()
      expect(hasProperties).to.be.true

  describe '#propertiesByKey()', ->

    it 'when no properties exist', ->
      model.visibleProperties = -> []
      result = model.propertiesByKey()
      expect(result).to.eql []

    it 'groups properties by key', ->
      property1 = new Backbone.Model key: 'source'
      property2 = new Backbone.Model key: 'lenoch code'
      property3 = new Backbone.Model key: 'source'
      model.visibleProperties = -> [property1, property2, property3]
      result = model.propertiesByKey()
      expect(result).to.have.lengthOf 2
      source = _(result).findWhere key: 'source'
      expect(source).to.eql
        key: 'source'
        properties: [property1, property3]

    it 'sorts groups by lang precedence', ->
      property1 = new Backbone.Model key: 'src', lang: 'de'
      property2 = new Backbone.Model key: 'src', lang: 'en'
      property3 = new Backbone.Model key: 'src', lang: 'de'
      model.visibleProperties = -> [property1, property2, property3]
      result = model.propertiesByKey precedence: ['en', 'de']
      group = result[0].properties
      expect(group).to.eql [property2, property1, property3]

    it 'appends properties with other lang', ->
      property1 = new Backbone.Model key: 'src', lang: 'fr'
      property2 = new Backbone.Model key: 'src', lang: 'de'
      property3 = new Backbone.Model key: 'src', lang: 'en'
      model.visibleProperties = -> [property1, property2, property3]
      result = model.propertiesByKey precedence: ['en', 'de']
      group = result[0].properties
      expect(group).to.eql [property3, property2, property1]
