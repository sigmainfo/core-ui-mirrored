#= require environment

class Coreon.Views.Panels.PanelView extends Backbone.View

  className: 'panel'

  widgetize: ->
    @$el.addClass 'widget'
