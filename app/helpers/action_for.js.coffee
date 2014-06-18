#= require environment
#= require templates/helpers/action_for

Coreon.Helpers.action_for = (id, options = {}) ->
  name = _.last(id.split '.').replace /_/g, '-'
  name = [name, className].join ' ' if className = options.className

  label = I18n.t "#{id}.label", defaultValue: I18n.t(id)
  hint =  I18n.t "#{id}.hint" , defaultValue: label

  Coreon.Templates['helpers/action_for']
    name: name
    label: label
    hint: hint
