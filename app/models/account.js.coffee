#= require environment

class Coreon.Models.Account extends Backbone.Model

  idle: ->
    not CoreClient.Auth.isAuthenticated()
