#= require environment
#= require models/panel

class Coreon.Collections.Panels extends Backbone.Collection

  @instance = ->
    @_instance ?= new @ [
      {type: 'concepts', widget: off}
      {type: 'clipboard', height: 80}
      {type: 'conceptMap'}
      {type: 'termList'}
    ]

  model: Coreon.Models.Panel

  initialize: ->
    @off()

    @on 'change:width'
      , @syncWidgetWidths
      , @

    @on 'change:widget'
      , @cyclePanels
      , @

  syncWidgetWidths: (model, value, options) ->
    if model.get('widget')
      @forEach (panel) ->
        panel.set 'width', value

  cyclePanels: (model, value, options) ->
    if value is off
      @forEach (panel) ->
        panel.set 'widget', on unless panel is model
