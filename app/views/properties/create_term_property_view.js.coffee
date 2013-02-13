#= require environment
#= require templates/properties/create_property

class Coreon.Views.Properties.CreateTermPropertyView extends Backbone.View

  className: "create-term-property"

  template: Coreon.Templates["properties/create_property"]

  events:
    'click .remove_property': 'remove_property'
    'change input': 'input_changed'
  
  input_changed: (event) ->
    input = $(event.target)
    [all, key] = input[0].name.match /\[([^[]*)\]$/
    terms = @model.get "terms"
    term = terms[@options.term_id]
    term.properties[@options.id][key] = input.val()
    @model.set "terms", terms

  render: ->
    @$el.empty()
    prefix = "concept[terms][#{@options.term_id}][properties]"
    @$el.html @template property: @options.property, id: @options.id, prefix: prefix

  remove_property: (event) =>
    input = $(event.target)
    properties = @model.get "properties"
    properties.splice input.attr("data-id"), 1
    @model.set "properties", properties
    @$el.empty()

