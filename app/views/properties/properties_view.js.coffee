#= require environment
#= require templates/properties/properties
#= require templates/properties/property

class Coreon.Views.Properties.PropertiesView extends Backbone.View

  tagName: 'section'

  className: 'properties'

  initialize: (options = {}) ->
    _(options).defaults
      app      : Coreon.application
      template : Coreon.Templates['properties/properties']

    @app      = options.app
    @template = options.template

    @stopListening()
    @listenTo @model, 'change', @render

  render: ->
    index = @model.groupBy (property) -> property.get 'key'

    langs = @app.langs()
    langComparator = (property) ->
      lang = property.get('lang')
      position = langs.indexOf(lang)
      if position >= 0 then position else langs.length

    properties = _(index).map (list, key) ->
      sorted = _(list).sortBy langComparator
      key: key
      properties: sorted

    @$el.html @template
      properties: properties
    @
