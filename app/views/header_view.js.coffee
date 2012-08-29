#= require environment
#= require views/notifications_view

class Coreon.Views.HeaderView extends Backbone.View
  id: "coreon-header"

  events:
    "animate .notification": "onAnimate"

  initialize: ->
    @notifications = new Coreon.Views.NotificationsView collection: @collection
    @height = @$el.height()

  render: ->
    @$el.append @notifications.render().$el
    @

  onAnimate: ->
    @trigger "resize"
