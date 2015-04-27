#= require environment
#= require helpers/action_for
#= require templates/helpers/titlebar_editmap

Coreon.Helpers.titlebar_editmap = ( title, actions = [] ) ->
  Coreon.Templates['helpers/titlebar_editmap']
    title: title
    actions: actions