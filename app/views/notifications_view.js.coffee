#= require environment
#= require views/notification_view

class Coreon.Views.NotificationsView extends Backbone.View
  tagName: "ul"
  className: "notifications"

  initialize: ->
    @collection.on "add", @onAdd, @
    @collection.on "reset", @render, @

  render: ->
    @clear()
    for model in @collection.models
      @$el.append new Coreon.Views.NotificationView(model: model).render().$el
    @

  clear: ->
    @$el.empty()

  onAdd: (model) ->
    @$el.prepend new Coreon.Views.NotificationView(model: model).render().$el
