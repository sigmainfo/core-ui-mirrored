class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = [], @errors = []) ->

  all: ->

    props = []
    unused_properties = @properties.slice 0

    for blue_prop in @blueprint_properties
      property = _.find @properties, (p) -> p.get('key') == blue_prop.key
      value = blue_prop.default
      errors = {}
      lang = null

      if property
        value = property.get 'value'
        lang = property.get 'lang'
        unused_index = unused_properties.indexOf property
        unused_properties.splice unused_index, 1
        index = @properties.indexOf property
        errors = @errors[index] || {}

      new_property =
        value: value
        type: blue_prop.type
        key: blue_prop.key
        errors: errors

      if blue_prop.type in ['text', 'multiline_text']
        new_property.lang = lang

      props.push new_property


    for property in unused_properties
      index = @properties.indexOf property
      props.push
        value: property.get 'value'
        type: 'text'
        key: property.get 'key'
        lang: property.get 'lang'
        errors: @errors[index] || {}

    props


