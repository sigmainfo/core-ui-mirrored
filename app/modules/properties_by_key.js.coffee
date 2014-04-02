#= require environment

Coreon.Modules.PropertiesByKey =

  hiddenProperties: []

  propertiesByKey: (options) ->
    unless options?
      props = {}
      for prop in @properties().models
        key = prop.get "key"
        unless key in @hiddenProperties
          props[key] ?= []
          props[key].push prop
      props
    else
      options.precedence ?= []
      precedence = options.precedence
      groups = @properties().groupBy('key')
      for key, properties of groups when key not in @hiddenProperties
        key: key
        properties: properties.sort (a, b) ->
          [a, b] = [a, b].map (property) ->
            lang = property.get('lang')
            pos = precedence.indexOf lang
            pos = precedence.length if pos < 0
            pos
          a - b

  propertiesByKeyAndLang: ->
    props = {}

    if settings = Coreon.application?.repositorySettings()
      sourceLang = settings.get('sourceLanguage')
      targetLang = settings.get('targetLanguage')

      sourceLang = null if sourceLang == 'none'
      targetLang = null if targetLang == 'none'

    for key, list of @propertiesByKey()
      do (key, list) ->
        sourceLangProps = []
        targetLangProps = []
        otherLangProps = []

        for item in list
          do (item) ->
            if itemLang = item.get('lang')
              if sourceLang and itemLang == sourceLang
                sourceLangProps.push item
              else
                if targetLang and itemLang == targetLang
                  targetLangProps.push item
                else
                  otherLangProps.push item
            else
              otherLangProps.push item

          props[key] = sourceLangProps.concat targetLangProps, otherLangProps
    props


