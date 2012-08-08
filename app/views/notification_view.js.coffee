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
    @$el.html @template message: @model.get("message"), url: @model.url
    @$el.hide() if @model.get "hidden"
    @
  
  hide: (event) ->
    @model.hide() 
    event.preventDefault()
    event.stopPropagation()

  onChangeHidden: =>
    if @model.get "hidden" then @$el.hide() else @$el.show()
