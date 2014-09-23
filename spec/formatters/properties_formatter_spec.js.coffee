#= require spec_helper
#= require formatters/properties_formatter
#= require models/property

describe "Coreon.Formatters.PropertiesFormatter", ->

  formatter = null
  blueprint_properties = null
  properties = null

  fakeProperty =  ->
    new Backbone.Model()

  fakeBlueprintProperty =  ->
    {key: 'label', type: 'text'}

  propertyKeys = (arr) ->
    $.map arr, (el) -> el.key

  beforeEach ->
    blueprint_properties = []
    properties = []
    formatter = new Coreon.Formatters.PropertiesFormatter blueprint_properties, properties

  describe "#all()", ->

    it 'defaults to empty array', ->
      properties = []
      blueprint_properties = []
      all = formatter.all()
      expect(all).to.be.instanceOf Array
      expect(all).to.be.empty

    context 'single item', ->

      context 'with no blueprint defaults', ->

        it 'fetches model from property', ->
          property = fakeProperty()
          properties.push property
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'model', property

        it 'fetches key from property', ->
          property = fakeProperty()
          property.set 'key', 'test'
          properties.push property
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'key', 'test'

        it 'fetches null type', ->
          property = fakeProperty()
          properties.push property
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'type', 'text'

      context 'only blueprint defaults', ->

        it 'fetches null model', ->
          blueprint_property = fakeBlueprintProperty()
          blueprint_properties.push blueprint_property
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'model', null

        it 'fetches key from blueprint property', ->
          blueprint_properties.push {key: 'test', type: 'boolean'}
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'key', 'test'

        it 'fetches type from blueprint property', ->
          blueprint_properties.push {key: 'test', type: 'boolean'}
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'type', 'boolean'

      context 'combined with blueprint defaults', ->

        it 'combines a property with the relative default property', ->
          property = fakeProperty()
          property.set 'key', 'dangerous'
          properties.push property
          blueprint_properties.push {key: 'dangerous', type: 'boolean'}
          all = formatter.all()
          formatted = all[0]
          expect(all).to.have.lengthOf 1
          expect(formatted).to.have.property 'model', property
          expect(formatted).to.have.property 'key', 'dangerous'
          expect(formatted).to.have.property 'type', 'boolean'

        it 'doesn\'t combine properties with different key', ->
          property = fakeProperty()
          property.set 'key', 'dangerous'
          properties.push property
          blueprint_properties.push {key: 'cool', type: 'boolean'}
          all = formatter.all()
          keys = $.map all, (el) -> el.key
          expect(all).to.have.lengthOf 2
          expect(keys).to.include 'dangerous'
          expect(keys).to.include 'cool'

    context 'multiple items', ->

      context 'with no blueprint defaults', ->

        it 'collects all properties', ->
          property = fakeProperty()
          property.set 'key', 'label'
          properties.push property
          property = fakeProperty()
          property.set 'key', 'definition'
          properties.push property
          all = formatter.all()
          expect(all).to.have.lengthOf 2
          expect(propertyKeys all).to.include 'label'
          expect(propertyKeys all).to.include 'definition'

      context 'only with blueprint defaults', ->

        it 'collects all blueprint properties', ->
          blueprint_properties.push {key: 'label', type: 'text'}
          blueprint_properties.push {key: 'definition', type: 'text'}
          all = formatter.all()
          expect(all).to.have.lengthOf 2
          expect(propertyKeys all).to.include 'label'
          expect(propertyKeys all).to.include 'definition'

      context 'combined with blueprint defaults', ->

        it 'combines properties only with relative default properties', ->
          property = fakeProperty()
          property.set 'key', 'label'
          properties.push property
          property = fakeProperty()
          property.set 'key', 'definition'
          properties.push property
          property = fakeProperty()
          property.set 'key', 'ISBN'
          properties.push property
          blueprint_properties.push {key: 'label', type: 'text'}
          blueprint_properties.push {key: 'definition', type: 'text'}
          blueprint_properties.push {key: 'author', type: 'text'}
          all = formatter.all()
          expect(all).to.have.lengthOf 4
          expect(propertyKeys all).to.include 'label'
          expect(propertyKeys all).to.include 'definition'
          expect(propertyKeys all).to.include 'ISBN'
          expect(propertyKeys all).to.include 'author'

        it 'collects properties in the order defined in blueprints', ->
          property = fakeProperty()
          property.set 'key', 'label'
          properties.push property
          property = fakeProperty()
          property.set 'key', 'definition'
          properties.push property
          property = fakeProperty()
          property.set 'key', 'ISBN'
          properties.push property
          blueprint_properties.push {key: 'definition', type: 'text'}
          blueprint_properties.push {key: 'author', type: 'text'}
          blueprint_properties.push {key: 'label', type: 'text'}
          all = formatter.all()
          expect(all).to.have.lengthOf 4
          expect((propertyKeys all).slice 0, 3).to.eql ['definition', 'author', 'label']

