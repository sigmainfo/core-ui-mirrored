#= require environment
#= require templates/notification

class Coreon.Views.NotificationView extends Backbone.View
  tagName: "li"
  className: "notification"

  template: Coreon.Templates["notification"]

  events:
    "click a.hide": "hide"
  
  initialize: ->
    @model.on "change:hidden", @onChangeHidden

  render: ->
    @$el.html @template message: @model.message, url: @model.url
    @
  
  hide: (event) ->
    @model.hide() 
    event.preventDefault()
    event.stopPropagation()

  onChangeHidden: =>
    @remove() if @model.get "hidden"
