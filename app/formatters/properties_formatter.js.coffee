class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = []) ->

  all: ->

    props = []
    unused_properties = @properties.slice 0

    for blue_prop in @blueprint_properties
      property = _.find(@properties, (p) -> p.get('key') == blue_prop.key)
      model = null
      if property
        model = property
        index = unused_properties.indexOf property
        unused_properties.splice index, 1
      props.push
        model: model
        type: blue_prop.type
        key: blue_prop.key

    for prop in unused_properties
      props.push
        model: prop
        type: 'text'
        key: prop.get 'key'

    props


