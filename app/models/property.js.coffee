#= require environment
#= require modules/helpers
#= require modules/system_info

class Coreon.Models.Property extends Backbone.Model

  Coreon.Modules.include @, Coreon.Modules.SystemInfo

  defaults: ->
    id: null
    key: ""
    value: null
    lang: null
    persisted: true
    asset: null
