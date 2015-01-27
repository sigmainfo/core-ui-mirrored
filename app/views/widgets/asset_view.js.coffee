#= require environment
#= require templates/widgets/asset_view

class Coreon.Views.Widgets.AssetView extends Backbone.View

  id: "asset-view"

  template: Coreon.Templates['widgets/asset_view']

  events:
    "click a.previous" : "previous"
    "click a.next"     : "next"
    "click .close a"   : "remove"

  initialize: (options) ->
    @collection = options.collection
    @current = options.current

  render: ->
    @$el.html @template asset: @collection.at(@current)
    @

  next: ->
    @current++
    @current = 0 if @current == @collection.length
    @render()

  previous: ->
    @current--
    @current = @collection.length - 1 if @current < 0
    @render()