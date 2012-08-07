#= require jquery
#= require underscore
#= require backbone
#= require hamlcoffee
#= require i18n
#= require i18n/translations
#= require core_client

window.Coreon              ?= {}

Coreon.Models              ?= {}

Coreon.Views               ?= {}
Coreon.Views.Layout        ?= {}
Coreon.Views.Account       ?= {}
Coreon.Views.Notifications ?= {}

Coreon.Helpers             ?= {}

Coreon.Routers             ?= {}

HAML.globals = -> Coreon.Helpers
