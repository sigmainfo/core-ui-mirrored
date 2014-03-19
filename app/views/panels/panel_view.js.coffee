#= require environment
#= require helpers/action_for

class Coreon.Views.Panels.PanelView extends Backbone.View

  className: 'panel'

  widgetize: ->
    @$el.addClass 'widget'
    if @$('.actions a.maximize').length is 0
      @$('.actions').append Coreon.Helpers.action_for('panel.maximize')
    @

  maximize: ->
    @$el.removeClass 'widget'
    @$('.actions a.maximize').remove()
    @
