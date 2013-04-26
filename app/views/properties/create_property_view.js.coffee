#= require environment
#= require templates/properties/create_property

class Coreon.Views.Properties.CreatePropertyView extends Backbone.View

  className: "create-property"

  template: Coreon.Templates["properties/create_property"]

  events:
    'click .remove_property': 'remove_property'

  render: ->
    @$el.empty()
    @$el.html @template
      id: @options.index
      key: @key
      value: @value
      lang: @lang
    @

  remove_property: ->
    @remove()

  validationFailure: (index, errors) ->
    @$('.input').removeClass 'error'
    @$('.error_message').empty()
    if @options.index == index
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


