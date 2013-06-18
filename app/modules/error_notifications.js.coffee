#= require environment
#= require models/notification

Coreon.Modules.ErrorNotifications =

  failHandler: (xhr, status, error) ->
    if xhr.status is 0
      message = I18n.t("errors.service.unavailable")
    else
      try
        response = JSON.parse xhr.responseText
      catch error
        console?.log "[Backbone.ajax] #{error}"
      finally
        response ?= {}
        response.message ?= I18n.t "errors.generic"
        message = if response.code
          I18n.t response.code, defaultValue: response.message
        else
          response.message
    Coreon.Models.Notification.error message
