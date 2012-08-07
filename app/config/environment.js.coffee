#= require jquery
#= require underscore
#= require backbone
#= require hamlcoffee
#= require i18n
#= require i18n/translations
#= require core_client

window.Coreon              ?= {}

Coreon.Models              ?= {}
Coreon.Collections         ?= {}
Coreon.Helpers             ?= {}
Coreon.Routers             ?= {}

Coreon.Views               ?= {}
Coreon.Views.Layout        ?= {}


HAML.globals = -> Coreon.Helpers
