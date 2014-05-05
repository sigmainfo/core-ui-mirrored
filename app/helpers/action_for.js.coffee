#= require environment
#= require templates/helpers/action_for

Coreon.Helpers.action_for = (id, options = {}) ->
  name = _.last(id.split '.').replace /_/g, '-'
  name = [name, className].join ' ' if className = options.className
  Coreon.Templates['helpers/action_for']
    name: name
    title: I18n.t(id)
