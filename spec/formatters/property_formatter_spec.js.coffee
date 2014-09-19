#= require spec_helper
#= require formatters/property_formatter

describe "Coreon.Formatters.PropertyFormatter", ->

  formatter = null
  
  context "#format", ->

    beforeEach ->
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
        {
          key: 'label'
          value: 'This is a label'
        },
        {
          key: 'definition'
          type: 'This is a definition'
        }
      ]

      formatter = new Coreon.Formatters.PropertyFormatter(blueprint_properties, properties)

    it "returns a combination of default and given properties", ->
      formatted_properties = formatter.format()
      expect(formatted_properties).to.have.length(3)
