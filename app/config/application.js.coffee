#= require environment
#= require views/layout/application_view

class Coreon.Application
  init: (options = {}) ->
    options.el ?= "#app"
    layout = new Coreon.Views.Layout.ApplicationView el: options.el
    layout.render()
    @
