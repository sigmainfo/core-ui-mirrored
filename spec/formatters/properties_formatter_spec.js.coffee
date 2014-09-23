#= require spec_helper
#= require formatters/properties_formatter
#= require models/property

describe "Coreon.Formatters.PropertiesFormatter", ->

  formatter = null
  blueprint_properties = null
  properties = null

  clear = (properties) ->
    while properties.length > 0
      properties.pop

  fakeProperties = (arr, properties_attrs) ->
    clear(arr)
    properties_attrs.forEach (attrs) ->
      arr.push new Backbone.Model(attrs)

  fakeProperty =  ->
    new Backbone.Model()

  fakeBlueprintProperty =  ->
    {key: 'label', type: 'text'}

  fakeBlueprintProperties = (arr, properties_attrs) ->
    clear(arr)
    properties_attrs.forEach (attrs) ->
      arr.push attrs

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

        beforeEach ->
          clear blueprint_properties

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

        beforeEach ->
          clear properties

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
          fakeProperties properties, [
            {key: 'dangerous'}
          ]
          fakeBlueprintProperties blueprint_properties, [
            {key: 'cool', type: 'boolean'}
          ]
          all = formatter.all()
          expect(all).to.have.lengthOf 2
          expect(propertyKeys all).to.include 'dangerous'
          expect(propertyKeys all).to.include 'cool'

    context 'multiple items', ->

      it 'collects all properties if no blueprint defaults are given', ->
        fakeProperties properties, [
          {key: 'label'},
          {key: 'definition'}
        ]
        all = formatter.all()
        expect(all).to.have.lengthOf 2
        expect(propertyKeys all).to.include 'label'
        expect(propertyKeys all).to.include 'definition'

      it 'collects all blueprint properties if no properties are given', ->
        fakeBlueprintProperties blueprint_properties, [
          {key: 'label', type: 'text'},
          {key: 'definition', type: 'text'}
        ]
        all = formatter.all()
        expect(all).to.have.lengthOf 2
        expect(propertyKeys all).to.include 'label'
        expect(propertyKeys all).to.include 'definition'

      describe 'combined with blueprint defaults', ->

        it 'combines properties only with relative default properties', ->
          fakeProperties properties, [
            {key: 'label'},
            {key: 'definition'},
            {key: 'ISBN'}
          ]
          fakeBlueprintProperties blueprint_properties, [
            {key: 'definition', type: 'text'}
            {key: 'author', type: 'text'},
            {key: 'label', type: 'text'}
          ]
          all = formatter.all()
          expect(all).to.have.lengthOf 4
          expect(propertyKeys all).to.include 'label'
          expect(propertyKeys all).to.include 'definition'
          expect(propertyKeys all).to.include 'ISBN'
          expect(propertyKeys all).to.include 'author'

        it 'collects properties in the order defined in blueprints', ->
          fakeProperties properties, [
            {key: 'label'},
            {key: 'definition'},
            {key: 'ISBN'}
          ]
          fakeBlueprintProperties blueprint_properties, [
            {key: 'definition', type: 'text'}
            {key: 'author', type: 'text'},
            {key: 'label', type: 'text'}
          ]
          all = formatter.all()
          expect(propertyKeys all).to.eql ['definition', 'author', 'label', 'ISBN']

