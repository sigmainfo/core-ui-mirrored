#= require environment
#= require templates/properties/create_property

class Coreon.Views.Properties.CreatePropertyView extends Backbone.View

  className: "create-property"

  template: Coreon.Templates["properties/create_property"]

  events:
    'change input': 'input_changed'
    'click .remove_property': 'remove_property'

  initialize: ->
    @listenTo @model, 'validationFailure:property', @validationFailure
  
  input_changed: (event) ->
    input = $(event.target)
    [all, key] = input[0].name.match /\[([^[]*)\]$/
    properties = @model.get "properties"
    if properties[@options.id][key] != input.val()
      properties[@options.id][key] = input.val()
      @model.set "properties", properties
      @model.trigger "change:properties"

  render: ->
    @$el.empty()
    @$el.html @template property: @options.property, id: @options.id, prefix: "concept[properties]"
    @

  remove_property: (event) ->
    properties = @model.get "properties"
    properties.splice @options.id, 1
    @model.set "properties", properties
    @model.trigger "change:properties remove:properties"

  validationFailure: (id, errors) ->
    @$('.input').removeClass 'error'
    @$('.error_message').empty()
    if @options.id == id
      if errors?.key?.length
        @$('.key .input').addClass 'error'
        if errors.key[0] is "can't be blank"
          @$('.key .error_message').html I18n.t "create_property.key_cant_be_blank"
      if errors?.value?.length
        @$('.value .input').addClass 'error'
        if errors.value[0] is "can't be blank"
          @$('.value .error_message').html I18n.t "create_property.value_cant_be_blank"
      if errors?.lang?.length
        @$('.language .input').addClass 'error'


