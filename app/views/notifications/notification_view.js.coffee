#= require environment
#= require templates/notifications/notification

class Coreon.Views.Notifications.NotificationView extends Backbone.View

  tagName: "li"

  className: "notification"

  template: Coreon.Templates["notifications/notification"]

  events:
    "click a.hide": "close"
  
  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "remove", @hide

  render: ->
    type = @model.get "type"
    @$el.removeClass().addClass "#{@className} #{type}"
    @$el.html @template
      message: @model.get("message")
      label: I18n.t "notification.label.#{type}"
    @
  
  close: ->
    @model.destroy()

  hide: ->
    @$el.slideUp
      duration: "slow"
      step: => @trigger "resize"
      complete: => @remove()

  show: ->
    @$el.slideDown
      duration: "slow"
      step: => @trigger "resize"

  remove: ->
    @off()
    super
