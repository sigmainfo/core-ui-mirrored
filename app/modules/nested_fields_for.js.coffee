#= require environment
#= require modules/nested_fields_for

Coreon.Modules.NestedFieldsFor =

  nestedFieldsFor: (attr, options = {}) ->
    options.name ?= attr[..-2]
    options.className ?= options.name
    options.as ?= options.name[0].toUpperCase() + options.name[1..]
    options.template ?= Coreon.Templates["#{attr}/new_#{options.name}"]

    @::["remove#{options.as}"] = (event) ->
      container = $(event.target).closest(".#{options.className}")
      if container.find('input[type=hidden][name*=_id]').length > 0
        container.addClass("delete")
      else
        container.remove()


    @::["add#{options.as}"] = (event) ->
      target = $(event.target)
      data = target.data()
      data.index ?= 0
      context = {}
      context[key] = value for key, value of data
      target.parent().before options.template context
      data.index += 1
