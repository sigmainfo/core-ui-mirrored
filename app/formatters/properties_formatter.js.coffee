class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = [], @errors = []) ->

  all: ->

    props = []
    unused_properties = @properties.slice 0

    for blue_prop in @blueprint_properties
      property = _.find @properties, (p) -> p.get('key') == blue_prop.key
      value = blue_prop.default
      errors = {}
      if property
        value = property.get 'value'
        unused_index = unused_properties.indexOf property
        unused_properties.splice unused_index, 1
        index = @properties.indexOf property
        errors = @errors[index] || {}
      props.push
        value: value
        type: blue_prop.type
        key: blue_prop.key
        errors: errors

    for property in unused_properties
      index = @properties.indexOf property
      props.push
        value: property.get 'value'
        type: 'text'
        key: property.get 'key'
        errors: @errors[index] || {}

    props


