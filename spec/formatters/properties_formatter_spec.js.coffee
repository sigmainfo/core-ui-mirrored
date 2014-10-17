#= require spec_helper
#= require formatters/properties_formatter
#= require models/property

describe "Coreon.Formatters.PropertiesFormatter", ->

  formatter = null
  blueprintProperties = null
  properties = null
  errors = null

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

  fakeErrors = (arr, error_attrs) ->
    clear(arr)
    error_attrs.forEach (attrs) ->
      arr.push attrs

  propertyKeys = (arr) ->
    $.map arr, (el) -> el.key

  beforeEach ->
    blueprintProperties = []
    properties = []
    errors = []
    formatter = new Coreon.Formatters.PropertiesFormatter blueprintProperties, properties, errors

  context "no errors", ->

    beforeEach ->
      clear errors

    describe "#all()", ->

      it 'defaults to empty array', ->
        clear properties
        clear blueprintProperties
        all = formatter.all()
        expect(all).to.be.instanceOf Array
        expect(all).to.be.empty


      context 'single property', ->

        context 'only blueprint defaults given, no property', ->

          beforeEach ->
            clear properties

          it 'fetches key from blueprint property', ->
            blueprintProperties.push {key: 'test', type: 'boolean'}
            all = formatter.all()
            formatted = all[0]
            expect(formatted).to.have.property 'key', 'test'

          it 'fetches type from blueprint property', ->
            blueprintProperties.push {key: 'test', type: 'boolean'}
            all = formatter.all()
            formatted = all[0]
            expect(formatted).to.have.property 'type', 'boolean'

          it 'fetches values from blueprint property if applicable', ->
            blueprintProperties.push
              key: 'test',
              type: 'multiselect_picklist',
              values: ['one', 'two']
            all = formatter.all()
            formatted = all[0]
            expect(formatted.values[0]).to.equal 'one'
            expect(formatted.values[1]).to.equal 'two'

          it 'fetches default value', ->
            blueprint_property = fakeBlueprintProperty()
            blueprint_property.default = 'somevalue'
            blueprintProperties.push blueprint_property
            all = formatter.all()
            formatted = all[0]
            expect(formatted.properties[0]).to.have.property 'value', 'somevalue'

          it 'fetches lang if applicable', ->
            blueprintProperties.push {key: 'test', type: 'text'}
            all = formatter.all()
            formatted = all[0]
            expect(formatted.properties[0]).to.have.property 'lang', null

          it 'does not fetch lang if not applicable', ->
            blueprintProperties.push {key: 'test', type: 'boolean'}
            all = formatter.all()
            formatted = all[0]
            expect(formatted.properties[0]).to.not.have.property 'lang'

        context 'both blueprint and property given', ->

          it 'combines a property with the relative default property', ->
            blueprintProperties.push {key: 'dangerous', type: 'boolean'}
            property = fakeProperty()
            property.set 'key', 'dangerous'
            property.set 'value', 'somevalue'
            properties.push property
            all = formatter.all()
            formatted = all[0]
            expect(all).to.have.lengthOf 1
            expect(formatted.properties[0]).to.have.property 'value', 'somevalue'
            expect(formatted).to.have.property 'key', 'dangerous'
            expect(formatted).to.have.property 'type', 'boolean'

          it 'doesn\'t combine properties with different key', ->
            fakeBlueprintProperties blueprintProperties, [
              {key: 'cool', type: 'boolean'}
            ]
            fakeProperties properties, [
              {key: 'dangerous'}
            ]
            all = formatter.all()
            expect(all).to.have.lengthOf 1
            expect(propertyKeys all).to.include 'cool'
            expect(propertyKeys all).to.not.include 'dangerous'

      context 'multiple items', ->

        it 'collects no properties if no blueprint defaults are given', ->
          clear blueprintProperties
          fakeProperties properties, [
            {key: 'label'},
            {key: 'definition'}
          ]
          all = formatter.all()
          expect(all).to.have.lengthOf 0

        it 'collects all blueprint properties if no properties are given', ->
          fakeBlueprintProperties blueprintProperties, [
            {key: 'label', type: 'text'},
            {key: 'definition', type: 'text'}
          ]
          clear properties
          all = formatter.all()
          expect(all).to.have.lengthOf 2
          expect(propertyKeys all).to.include 'label'
          expect(propertyKeys all).to.include 'definition'

        context 'combined with blueprint defaults', ->

          it 'combines properties only with relative default properties', ->
            fakeBlueprintProperties blueprintProperties, [
              {key: 'definition', type: 'text'}
              {key: 'author', type: 'text'},
              {key: 'label', type: 'text'}
            ]
            fakeProperties properties, [
              {key: 'label'},
              {key: 'definition'},
              {key: 'ISBN'}
            ]
            all = formatter.all()
            expect(all).to.have.lengthOf 3
            expect(propertyKeys all).to.include 'definition'
            expect(propertyKeys all).to.include 'author'
            expect(propertyKeys all).to.include 'label'

          it 'collects properties in the order defined in blueprints', ->
            fakeBlueprintProperties blueprintProperties, [
              {key: 'definition', type: 'text'}
              {key: 'author', type: 'text'},
              {key: 'label', type: 'text'}
            ]
            fakeProperties properties, [
              {key: 'label'},
              {key: 'definition'},
              {key: 'ISBN'}
            ]
            all = formatter.all()
            expect(propertyKeys all).to.eql ['definition', 'author', 'label']

        describe "multivalue fields", ->

          it 'groups properties with the same key', ->
            fakeProperties properties, [
              {key: 'label', value: 'first label'},
              {key: 'label', value: 'second label'},
              {key: 'definition', value: 'first definition'},
              {key: 'definition', value: 'second definition'},
              {key: 'definition', value: 'third definition'},
            ]
            fakeBlueprintProperties blueprintProperties, [
              {key: 'label', type: 'text'},
              {key: 'definition', type: 'text'}
            ]
            all = formatter.all()
            expect(all[0]).to.have.property 'key', 'label'
            expect(all[1]).to.have.property 'key', 'definition'
            expect(all[0].properties).to.have.lengthOf 2
            expect(all[1].properties).to.have.lengthOf 3

  context "with errors", ->

    describe "#all()", ->

      # it "collects errors from parent object", ->
      #   clear blueprintProperties
      #   fakeProperties properties, [
      #     {value: 'foo'},
      #     {key: 'baz', value: 'invalid chars in here, YOLO'},
      #   ]
      #   fakeErrors errors, [
      #     {key: ["can't be blank"]},
      #     {value: ["invalid characters"]}
      #   ]
      #   all = formatter.all()
      #   expect(all[0]['errors']).to.eql {key: ["can't be blank"]}
      #   expect(all[1]['errors']).to.eql {value: ["invalid characters"]}

      # it "collects errors only for invalid properties", ->
      #   fakeProperties properties, [
      #     {value: 'foo'},
      #     {key: 'koo', value: 'bar'}
      #     {key: 'baz', value: 'invalid chars in here, YOLO'},
      #   ]
      #   fakeErrors errors, [
      #     {key: ["can't be blank"]},
      #     null,
      #     {value: ["invalid characters"]}
      #   ]
      #   all = formatter.all()
      #   expect(all[0]['errors']).to.eql {key: ["can't be blank"]}
      #   expect(all[1]['errors']).to.eql {}
      #   expect(all[2]['errors']).to.eql {value: ["invalid characters"]}

      it "collects errors in order defined in blueprints", ->
        fakeBlueprintProperties blueprintProperties, [
          {key: 'baz', type: 'text'}
          {key: 'too', type: 'text'},
          {key: 'koo', type: 'text'}
        ]
        fakeProperties properties, [
          {key: 'koo', value: 'bar'}
          {key: 'baz', value: 'invalid chars in here, YOLO'},
        ]
        fakeErrors errors, [
          {value: ["too short"]},
          {value: ["invalid characters"]}
        ]
        all = formatter.all()
        expect(all[0].properties[0].errors).to.eql {value: ["invalid characters"]}
        expect(all[1].properties[0].errors).to.eql {}
        expect(all[2].properties[0].errors).to.eql {value: ["too short"]}

