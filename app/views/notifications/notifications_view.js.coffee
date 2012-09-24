#= require environment
#= require views/composite_view
#= require views/notifications/notification_view

class Coreon.Views.Notifications.NotificationsView extends Coreon.Views.CompositeView
  id: "coreon-notifications"
  tagName: "ul"
  className: "notifications"

  initialize: ->
    super
    @collection.on "add", @onAdd, @
    @collection.on "reset", @render, @

  render: ->
    @clear()
    for model in @collection.models
      @$el.append new Coreon.Views.Notifications.NotificationView(model: model).render().$el
    @

  clear: ->
    @$el.empty()

  onAdd: (model) ->
    model.set "hidden", true, silent: true
    @$el.prepend new Coreon.Views.Notifications.NotificationView(model: model).render().$el
    model.set "hidden", false
