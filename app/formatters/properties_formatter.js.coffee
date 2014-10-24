class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = [], @errors = [], @options = {}) ->

  all: ->

    props = []
    not_in_blueprints = @properties.map (p) -> p

    for blue_prop in @blueprint_properties
      found_properties = _.filter @properties, (p) -> p.get('key') == blue_prop.key
      properties = []

      for property in found_properties
        index = _.indexOf not_in_blueprints, property
        not_in_blueprints.splice index, 1
        index = @properties.indexOf property
        new_property =
          value: property.get 'value'
          errors: @errors[index] || {}
          info: property.info()
        if blue_prop.type in ['text', 'multiline_text']
          new_property.lang = property.get 'lang'
        properties.push new_property

      if _.isEmpty properties
        new_property =
          value: blue_prop.default
          errors: {}
          info: {}
        if blue_prop.type in ['text', 'multiline_text']
          new_property.lang = null
        properties.push new_property

      new_formatted_property =
        key: blue_prop.key
        type: blue_prop.type
        properties: properties

      if blue_prop.type in ['multiselect_picklist']
        new_formatted_property.values = blue_prop.values
      if blue_prop.type in ['boolean']
        new_formatted_property.labels = blue_prop.labels

      if !_.isEmpty(found_properties) || blue_prop.required || @options.includeOptional
        props.push new_formatted_property


    if @options.includeUndefined
      for property in not_in_blueprints
        new_property =
          value: property.get 'value'
          lang: property.get 'lang'
          errors: {}
          info: property.info()
        new_formatted_property =
          key: property.get 'key'
          type: 'text'
          properties: [new_property]
        props.push new_formatted_property

    props


