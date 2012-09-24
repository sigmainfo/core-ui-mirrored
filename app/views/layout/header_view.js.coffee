#= require environment
#= require views/composite_view
#= require views/notifications/notifications_view

class Coreon.Views.Layout.HeaderView extends Coreon.Views.CompositeView
  id: "coreon-header"

  events:
    "animate .notification": "onAnimate"

  initialize: ->
    super
    @notifications = new Coreon.Views.Notifications.NotificationsView collection: @collection
    @height = @$el.height()

  render: ->
    @$el.append @notifications.render().$el
    @

  onAnimate: ->
    @trigger "resize"
