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
    
      sourceLang = undefined if sourceLang and sourceLang == 'none'
      targetLang = undefined if targetLang and targetLang == 'none'
    
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
    
      