#= require environment

Coreon.Modules.PropertiesByKey =

  propertiesByKey: ->
    props = {}
    for prop in @properties().models
      key = prop.get "key"
      props[key] ?= []
      props[key].push prop
    props

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

  propertiesByKeyAndType: (properties_settings) ->
    props = {}
    unused_properties = properties_settings.slice 0

    for prop in @properties().models
      key = prop.get "key"
      property_setting = _.findWhere(properties_settings, key: key)
      if property_setting?
        type = property_setting.type
        index = unused_properties.indexOf property_setting
        unused_properties.splice index, 1
      else
        type = ''
      props[key] ?= {}
      props[key][type] ?= []
      props[key][type].push prop

    for prop in unused_properties
      props[prop.key] ?= {}
      props[prop.key][prop.type] = []

    props

  propertiesByKeyTypeAndLang: (properties_settings) ->
    props = {}

    if settings = Coreon.application?.repositorySettings()
      sourceLang = settings.get('sourceLanguage')
      targetLang = settings.get('targetLanguage')

      sourceLang = null if sourceLang == 'none'
      targetLang = null if targetLang == 'none'

    for key, types of  @propertiesByKeyAndType(properties_settings)
      do (key, types) ->
        for type, list of types
          do (type, list) ->
            sourceLangProps = []
            targetLangProps = []
            otherLangProps = []

            if list.length > 0
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
              props[key] ?= {}
              props[key][type] ?= []
              props[key][type] = sourceLangProps.concat targetLangProps, otherLangProps
            else
              props[key] ?= {}
              props[key][type] = []

    props


