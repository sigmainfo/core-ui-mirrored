class Coreon.Formatters.PropertiesFormatter

  constructor: (@blueprint_properties = [], @properties = [], @errors = [], @options = {}) ->

  calculateDefault: (blue_prop) ->
    switch blue_prop.type
      when 'date'
        if blue_prop.default is 'now'
          today = new Date()
          today.toDateString()
        else
          blue_prop.default
      else
        blue_prop.default

  all: ->

    props = []
    not_in_blueprints = @properties.map (p) -> p

    for blue_prop in @blueprint_properties
      found_properties = _.filter @properties, (p) -> p.get('key') == blue_prop.key
      properties = []
      multivalue = if blue_prop.type in ['text', 'multiline_text', 'asset'] then true else false

      for property in found_properties
        index = _.indexOf not_in_blueprints, property
        not_in_blueprints.splice index, 1
        index = @properties.indexOf property
        new_property =
          value: if property.has('value') then  property.get('value') else @calculateDefault(blue_prop)
          errors: @errors[index] || {}
          info: property.info()
          persisted: if property.has('persisted') then property.get('persisted') else true
        if multivalue
          new_property.lang = property.get 'lang'
        properties.push new_property

      if _.isEmpty properties
        new_property =
          value: @calculateDefault(blue_prop)
          errors: {}
          info: {}
          persisted: false
        if multivalue
          new_property.lang = null
        properties.push new_property

      source_lang = []
      target_lang = []
      other_lang = []
      sourceLang = Coreon.application?.repositorySettings().get('sourceLanguage')
      targetLang = Coreon.application?.repositorySettings().get('targetLanguage')

      for property in properties
        if property.lang == sourceLang
          source_lang.push property
        else if property.lang == targetLang
          target_lang.push property
        else
          other_lang.push property

      sorted_properties = source_lang.concat target_lang, other_lang

      new_formatted_property =
        key: blue_prop.key
        type: blue_prop.type
        properties: sorted_properties
        required: blue_prop.required
        multivalue: multivalue

      if blue_prop.type in ['picklist', 'multiselect_picklist']
        new_formatted_property.values = blue_prop.values
      if blue_prop.type in ['boolean']
        new_formatted_property.labels = blue_prop.labels

      if !_.isEmpty(found_properties) || blue_prop.required || @options.includeOptional
        props.push new_formatted_property


    if @options.includeUndefined
      undefinedByKey = {}
      for property in not_in_blueprints
        key = property.get 'key'
        new_property =
          value: property.get 'value'
          lang: property.get 'lang'
          errors: {}
          info: property.info()
          persisted: true
        undefinedByKey[key] ?= []
        undefinedByKey[key].push new_property

      for key, properties of undefinedByKey
        new_formatted_property =
          key: key
          type: 'text'
          properties: properties
          nonDefined: true
        props.push new_formatted_property

    props


