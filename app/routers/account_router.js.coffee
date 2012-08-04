#= require environment

class Coreon.Routers.AccountRouter extends Backbone.Router

  routes:
    "account/logout": "logout"
    "account/login":  "login"

  logout: () ->
    CoreClient.Auth.authenticate false
    @navigate "account/login", trigger: true

  login: () ->
    console.log "logging in..."
