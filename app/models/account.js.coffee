#= require environment

class Coreon.Models.Account extends Backbone.Model

  idle: ->
    not CoreClient.Auth.isAuthenticated()

  logout: ->
    CoreClient.Auth.authenticate false
    @unset "userName"
    @trigger "logout"

  login: (login, password) ->
    CoreClient.Auth.authenticate login, password,
      success: =>
        @set "userName", CoreClient.Auth.getUserName()
        @trigger "login"

