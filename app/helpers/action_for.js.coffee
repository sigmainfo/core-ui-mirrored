#= require environment
#= require templates/helpers/action_for

Coreon.Helpers.action_for = ( id ) ->
  Coreon.Templates['helpers/action_for']
    name: _.last( id.split '.' ).replace '_', '-'
    title: I18n.t( id )
