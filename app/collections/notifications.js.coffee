#= require environment
#= require models/notification

class Coreon.Collections.Notifications extends Backbone.Collection

  model: Coreon.Models.Notification

  url: "notifications"

  destroy: ->
    @reset()
