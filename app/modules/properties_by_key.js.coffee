#= require environment

Coreon.Modules.PropertiesByKey =

    propertiesByKey: ->
      props = {}
      for prop in @properties().models
        key = prop.get "key"
        props[key] ?= []
        props[key].push prop
      props
