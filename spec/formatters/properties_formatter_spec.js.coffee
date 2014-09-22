#= require spec_helper
#= require formatters/properties_formatter
#= require models/property

describe "Coreon.Formatters.PropertiesFormatter", ->

  formatter = null
  
  context "#format", ->

    beforeEach ->
      blueprint_properties = [
        {
          key: 'label'
          type: 'text'
        }
      ]

      properties = [
        new Coreon.Models.Property({
          key: 'label'
          value: 'This is a label'
        })
      ]

      formatter = new Coreon.Formatters.PropertiesFormatter(blueprint_properties, properties)

    it 'returns an array', ->
      formatted_properties = formatter.format()
      expect(formatted_properties).to.be.instanceOf Array

    it 'returns an array of formatted properties', ->
      formatted_properties = formatter.format()
      formatted_property = formatted_properties[0]
      expect(formatted_property).to.have.property 'model'
      expect(formatted_property).to.have.property 'type'
      expect(formatted_property).to.have.property 'key'

    it 'returns a combination of default and given properties', ->
      blueprint_properties = [
        {
          key: 'label'
          type: 'text'
        },
        {
          key: 'dangerous'
          type: 'boolean'
        }
      ]

      properties = [
        new Coreon.Models.Property({
          key: 'label'
          value: 'This is a label'
        }),
        new Coreon.Models.Property({
          key: 'definition'
          type: 'This is a definition'
        })
      ]

      formatter = new Coreon.Formatters.PropertiesFormatter(blueprint_properties, properties)
      formatted_properties = formatter.format()
      expect(formatted_properties).to.have.length(3)
