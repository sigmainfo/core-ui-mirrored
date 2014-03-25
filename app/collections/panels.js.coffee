#= require environment
#= require models/panel

class Coreon.Collections.Panels extends Backbone.Collection

  @defaults:
    [
      {type: 'concepts', widget: off}
      {type: 'clipboard', height: 80}
      {type: 'conceptMap'}
      {type: 'termList'}
    ]

  @instance: =>
    @_instance ?= new @ @defaults

  model: Coreon.Models.Panel

  initialize: ->
    @off()

    @on 'change:width'
      , @syncWidgetWidths
      , @

    @on 'change:widget'
      , @cyclePanels
      , @

    @on 'change'
      , @saveSettings
      , @

  load: ->
    stored = Coreon.application?.repositorySettings 'panels'
    @reset(Coreon.Collections.Panels.defaults)

  syncWidgetWidths: (model, value, options) ->
    if model.get('widget')
      @forEach (panel) ->
        panel.set 'width', value

  cyclePanels: (model, value, options) ->
    if value is off
      @forEach (panel) ->
        panel.set 'widget', on unless panel is model

  saveSettings = ->
    Coreon.application?.repositorySettings 'panels', @toJSON()

  saveSettings: _(saveSettings).debounce 300
