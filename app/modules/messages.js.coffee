#= require namespace

notification = ->
  notifications = Coreon.application?.session?.notifications
  notifications.unshift.apply notifications, arguments if notifications

Coreon.Modules.Messages =

  message: (message, attributes = {}) ->
    attributes.message = message
    notification attributes
