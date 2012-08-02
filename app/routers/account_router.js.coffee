#= require environment

class Coreon.Routers.AccountRouter extends Backbone.Router

  routes:
    "account/logout": "logout"

  logout: () ->
    console.log "logging out ..."
