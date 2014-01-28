#= require environment
#= require helpers/action_for
#= require templates/helpers/titlebar

Coreon.Helpers.titlebar = ( title, actions = [] ) ->
  Coreon.Templates['helpers/titlebar']
    title: title
    actions: actions
