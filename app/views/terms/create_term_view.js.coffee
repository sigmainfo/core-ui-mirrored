#= require environment
#= require templates/terms/create_term

class Coreon.Views.Terms.CreateTermView extends Backbone.View

  className: "create-term"

  template: Coreon.Templates["terms/create_term"]

  events:
    'change input': 'input_changed'
    'click .remove_term': 'remove_term'

  initialize: ->
    @listenTo @model, 'validationFailure', @validationFailure

  render: ->
    @$el.empty()
    @$el.html @template term: @model, id: @model.cid
    @

  input_changed: (event) ->
    element = $(event.target)
    [all, attr] = element[0].name.match /\[([^[]+)\]$/
    @model.set attr, element[0].value

  remove_term: (event) ->
    @model.collection?.remove @model

  validationFailure: (errors) ->
    @$('.input').removeClass 'error'
    @$('.error_message').empty()
    if errors?.value?.length
      @$('.value .input').addClass 'error'
      if errors?.value?[0] is "can't be blank"
        @$('.value .error_message').html I18n.t "create_term.value_cant_be_blank"
    if errors?.lang?.length
      @$('.language .input').addClass 'error'
      if errors?.lang?[0] is "can't be blank"
        @$('.language .error_message').html I18n.t "create_term.language_cant_be_blank"


