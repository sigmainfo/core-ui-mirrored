#= require environment

class Coreon.Models.Connection extends Backbone.Model

  initialize: ->
    @get("xhr")
      .fail(@onFail)
      .always(@onComplete)

  onComplete: =>
    @destroy()
  
  onFail: (xhr, statusText, message)=>
    @trigger "error error:#{xhr.status}"
    switch xhr.status
      when 0
        @message I18n.t("errors.service.unavailable"), type: "error" 
      when 403
        @trigger "unauthorized"
      else
        error = code: "errors.generic"
        if xhr?.responseText?.length > 1
          try
            response = JSON.parse(xhr.responseText)
            _(error).extend _(response).pick "code", "message"
          catch error
            console?.log error.toString()
        @message I18n.t(error.code, defaultValue: error.message), type: "error"
