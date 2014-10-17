class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = [], @errors = []) ->

  all: ->

    props = []

    for blue_prop in @blueprint_properties
      found_properties = _.filter @properties, (p) -> p.get('key') == blue_prop.key
      properties = []

      for property in found_properties
        index = @properties.indexOf property
        new_property =
          value: property.get 'value'
          errors: @errors[index] || {}
        if blue_prop.type in ['text', 'multiline_text']
          new_property.lang = property.get 'lang'
        properties.push new_property

      if _.isEmpty properties
        new_property =
          value: blue_prop.default
          errors: {}
        if blue_prop.type in ['text', 'multiline_text']
          new_property.lang = null
        properties.push new_property

      new_formatted_property =
        key: blue_prop.key
        type: blue_prop.type
        properties: properties

      if blue_prop.type in ['multiselect_picklist']
        new_formatted_property.values = blue_prop.values

      props.push new_formatted_property

    props


