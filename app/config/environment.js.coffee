#= require jquery
#= require underscore
#= require backbone
#= require hamlcoffee
#= require i18n
#= require i18n/translations
#= require core_client

window.Coreon =
  Models: {}
  Collections: {}
  Helpers: {}
  Views:
    Widgets: {}
  Routers: {}

HAML.globals = -> Coreon.Helpers
