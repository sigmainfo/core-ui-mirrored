#= require jquery
#= require underscore
#= require backbone
#= require hamlcoffee
#= require i18n
#= require i18n/translations
#= require namespace

HAML.globals = -> Coreon.Helpers

# Quickfix to make plain Backbone views behave like SimpleView
Backbone.View::destroy = ->
  @remove()

ajaxWithoutErrorNotifications = Backbone.ajax
ajaxWithErrorNotifications = ->
  ajaxWithoutErrorNotifications(arguments...).fail Coreon.Modules.ErrorNotifications?.failHandler
Backbone.ajax = ajaxWithErrorNotifications
