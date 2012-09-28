#= require environment
#= require templates/notifications/notification

class Coreon.Views.Notifications.NotificationView extends Coreon.Views.SimpleView
  tagName: "li"
  className: "notification"

  template: Coreon.Templates["notifications/notification"]

  events:
    "click a.hide": "hide"
  
  initialize: ->
    @model.on "change:hidden", @onChangeHidden, @

  render: ->
    type = @model.get "type"
    @$el.html @template message: @model.get("message"), url: "/notification/hide", label: I18n.t "notification.label.#{type}"
    @$el.addClass type
    @$el.hide() if @model.get "hidden"
    @
  
  hide: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.set "hidden", true 

  onChangeHidden: ->
    [type, duration] =
      if @model.get "hidden"
        ["hide", "fast"]
      else
        ["show", 400]
    @$el.animate {
      height: type
    },
      duration: duration
      step: @onStep

  onStep: =>
    @$el.trigger "animate"
