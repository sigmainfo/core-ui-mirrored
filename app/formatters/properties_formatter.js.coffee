class Coreon.Formatters.PropertiesFormatter

  constructor: (blueprint_properties, properties) ->
    @blueprint_properties = if blueprint_properties? then blueprint_properties else []
    @properties = if properties? then properties else []

  all: ->
    # (model: property for property in @properties)
    props = []
    unused_properties = @blueprint_properties.slice 0

    for prop in @properties
      key = prop.get "key"
      type = null
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
