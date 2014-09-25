class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = [], @errors = []) ->

  all: ->

    props = []
    unused_properties = @properties.slice 0

    for blue_prop in @blueprint_properties
      property = _.find @properties, (p) -> p.get('key') == blue_prop.key
      model = null
      errors = {}
      if property
        model = property
        unused_index = unused_properties.indexOf property
        unused_properties.splice unused_index, 1
        index = @properties.indexOf property
        errors = @errors[index] || {}
      props.push
        model: model
        type: blue_prop.type
        key: blue_prop.key
        errors: errors

    for property in unused_properties
      index = @properties.indexOf property
      props.push
        model: property
        type: 'text'
        key: property.get 'key'
        errors: @errors[index] || {}

    props


