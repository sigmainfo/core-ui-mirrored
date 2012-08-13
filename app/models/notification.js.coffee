#= require environment

class Coreon.Models.Notification extends Backbone.Model

  urlRoot: "notifications"

  defaults:
    hidden: false
    type: "info"
