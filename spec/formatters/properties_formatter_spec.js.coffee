#= require spec_helper
#= require formatters/properties_formatter
#= require models/property

describe "Coreon.Formatters.PropertiesFormatter", ->

  formatter = null
  blueprint_properties = null
  properties = null

  fakeProperty = (options = {key: 'some_key'}) ->
    new Backbone.Model(options)

  fakeBlueprintProperty = (options = {key: 'label', type: 'text'}) ->
    options

  beforeEach ->
    properties = []
    blueprint_properties = []
    formatter = new Coreon.Formatters.PropertiesFormatter properties, blueprint_properties

  describe "#all()", ->

    it 'defaults to empty array', ->
      all = formatter.all()
      expect(all).to.be.instanceOf Array
      expect(all).to.be.empty

    context 'single item', ->

      property = null
      blueprint_property = null

      beforeEach ->
        property = null
        blueprint_property = null

      context 'with no blueprint defaults', ->

        beforeEach ->
          property = fakeProperty()
          formatter.properties = []

        it 'fetches model from property', ->
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'model', property

        it 'fetches key from property', ->
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'key', property.get 'key'

        # TODO 140923 [ap, tc] should rather default to 'text'
        it 'fetches null type', ->
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'type', null

      context 'only blueprint defaults', ->

        beforeEach ->
          blueprint_property = fakeBlueprintProperty()
          blueprint_properties.push blueprint_property
          formatter = new Coreon.Formatters.PropertiesFormatter blueprint_properties, null

        it 'fetches null model', ->
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'model', null

        it 'fetches key from blueprint property', ->
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'key', blueprint_property.key

        it 'fetches type from blueprint property', ->
          all = formatter.all()
          formatted = all[0]
          expect(formatted).to.have.property 'type', blueprint_property.type

      context 'combined with blueprint defaults', ->

        beforeEach ->
          blueprint_property = fakeBlueprintProperty({key: 'label', type: 'text'})
          blueprint_properties.push blueprint_property

        it 'combines a property with the relative default property', ->
          property = fakeProperty({key: 'label'})
          properties.push property
          formatter = new Coreon.Formatters.PropertiesFormatter blueprint_properties, properties
          all = formatter.all()
          formatted = all[0]
          expect(all).to.have.lengthOf 1
          expect(formatted).to.have.property 'model', property
          expect(formatted).to.have.property 'key', property.key
          expect(formatted).to.have.property 'type', blueprint_property.type

        it 'doesn\'t combine properties with different key', ->
          property = fakeProperty({key: 'definition'})
          properties.push property
          formatter = new Coreon.Formatters.PropertiesFormatter blueprint_properties, properties
          all = formatter.all()
          keys = $.map all, (el) -> el.key
          expect(all).to.have.lengthOf 2
          expect(keys).to.include 'label'
          expect(keys).to.include 'definition'

    context 'multiple items', ->

      context 'with no blueprint defaults', ->

        it 'collects all properties', ->
          properties.push fakeProperty({key: 'label'})
          properties.push fakeProperty({key: 'definition'})
          formatter = new Coreon.Formatters.PropertiesFormatter null, properties
          all = formatter.all()
          keys = $.map all, (el) -> el.key
          expect(all).to.have.lengthOf 2
          expect(keys).to.include 'label'
          expect(keys).to.include 'definition'

      context 'only with blueprint defaults', ->

        it 'collects all blueprint properties', ->
          blueprint_properties.push fakeBlueprintProperty({key: 'label', type: 'text'})
          blueprint_properties.push fakeBlueprintProperty({key: 'definition', type: 'text'})
          formatter = new Coreon.Formatters.PropertiesFormatter blueprint_properties, null
          all = formatter.all()
          keys = $.map all, (el) -> el.key
          expect(all).to.have.lengthOf 2
          expect(keys).to.include 'label'
          expect(keys).to.include 'definition'

      context 'combined with blueprint defaults', ->

        it 'combines properties only with relative default properties', ->
          properties.push fakeProperty({key: 'label'})
          properties.push fakeProperty({key: 'definition'})
          properties.push fakeProperty({key: 'ISBN'})
          blueprint_properties.push fakeBlueprintProperty({key: 'label', type: 'text'})
          blueprint_properties.push fakeBlueprintProperty({key: 'definition', type: 'text'})
          blueprint_properties.push fakeBlueprintProperty({key: 'author', type: 'text'})
          formatter = new Coreon.Formatters.PropertiesFormatter blueprint_properties, properties
          all = formatter.all()
          keys = $.map all, (el) -> el.key
          expect(all).to.have.lengthOf 4
          expect(keys).to.include 'label'
          expect(keys).to.include 'definition'
          expect(keys).to.include 'ISBN'
          expect(keys).to.include 'author'

          expect(keys all).t.eql ['label', 'definition', 'ISBN']



        # TODO 140922 [ap] What if one property is defined twice in blueprints and property exists once

      # TODO 140923 [tc] infer order from blueprint; append additional props
