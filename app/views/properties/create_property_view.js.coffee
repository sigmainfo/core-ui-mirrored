#= require environment
#= require templates/properties/create_property

class Coreon.Views.Properties.CreatePropertyView extends Backbone.View

  className: "create-property"

  template: Coreon.Templates["properties/create_property"]

  events:
    'click .remove_property': 'remove_property'
    'change input': 'input_changed'
  
  input_changed: (event) ->
    input = $(event.target)
    [all, key] = input[0].name.match /\[([^[]*)\]$/
    properties = @model.get "properties"
    properties[@options.id][key] = input.val()
    @model.set "properties", properties
    @model.trigger "change:properties"

  render: ->
    @$el.empty()
    @$el.html @template property: @options.property, id: @options.id, prefix: "concept[properties]"

  remove_property: (event) =>
    input = $(event.target)
    properties = @model.get "properties"
    properties.splice input.attr("data-id"), 1
    @model.set "properties", properties
    @model.trigger "change:properties"
    @$el.empty()

