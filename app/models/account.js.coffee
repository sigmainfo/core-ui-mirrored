#= require environment

class Coreon.Models.Account extends Backbone.Model

  idle: ->
    not CoreClient.Auth.isAuthenticated()

  logout: ->
    CoreClient.Auth.authenticate false
