#= require environment
#= require modules/helpers
#= require modules/system_info

class Coreon.Models.Property extends Backbone.Model

  Coreon.Modules.include @, Coreon.Modules.SystemInfo

  defaults: ->
    key: ""
    value: ""
    lang: ""
