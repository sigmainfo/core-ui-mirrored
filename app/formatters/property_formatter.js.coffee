class Coreon.Formatters.PropertyFormatter

  constructor: (blueprint_properties, properties) ->
    @blueprint_properties = blueprint_properties
    @properties = properties

  format: ->
    props = []
    unused_properties = @blueprint_properties.slice 0

    for prop in @properties
      key = prop.get "key"
      property_setting = _.findWhere(@blueprint_properties, key: key)
      if property_setting?
        type = property_setting.type
        index = unused_properties.indexOf property_setting
        unused_properties.splice index, 1
      props.push 
        model: prop
        type: type
        key: key

    for prop in unused_properties
      props.push 
        model: null
        type: prop.type
        key: prop.key

    props
