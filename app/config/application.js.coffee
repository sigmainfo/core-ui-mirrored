#= require environment
#= require views/application_view
#= require collections/notifications
#= require models/account

class Coreon.Application

  @defaults:
    el: "#app"
    root: "/"

  init: (options = {}) ->
    @options = _.defaults options, @constructor.defaults

    @notifications = new Coreon.Collections.Notifications
    @account       = new Coreon.Models.Account

    @account.on "logout", @onLogout, @
    @account.on "login", @onLogin, @

    @view = new Coreon.Views.ApplicationView
      el: @options.el
      model: @

    @view.render()

    $(document).ajaxError @ajaxErrorHandler

    Backbone.history ?= new Backbone.History
    Backbone.history.start
      pushState: true
      root: @options.root
      silent: true

    Coreon.application = @

  notify: (message = "") ->
    @notifications.unshift message: message

  alert: (message = "") ->
    @notifications.unshift message: message, type: "error"

  onLogout: ->
    @notify I18n.t "notifications.account.logout"

  onLogin: ->
    @notify I18n.t "notifications.account.login", name: @account.get "userName"

  ajaxErrorHandler: (event, jqXHR, ajaxSettings, thrownError) =>
    if @isApiUrl ajaxSettings.url
      if jqXHR.readyState is 0
        @alert I18n.t "errors.service.unavailable"
      else
        try
          data = JSON.parse jqXHR.responseText 
          data.message ?= I18n.t "errors.generic"
          if _.isString data.code
            @alert I18n.t data.code, defaultValue: data.message
          else
            @alert data.message
        catch e

  isApiUrl: (url) ->
    url.indexOf(CoreClient.Graph.root_url) > -1 or
    url.indexOf(CoreClient.Auth.root_url) > -1
