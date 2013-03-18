#= require environment
#= require templates/terms/create_term

class Coreon.Views.Terms.CreateTermView extends Backbone.View

  className: "create-term"

  template: Coreon.Templates["terms/create_term"]

  events:
    'click .remove_term': 'remove_term'

  render: ->
    @$el.empty()
    @$el.html @template
      id: @options.index
      value: @value ? ""
      language: @lang ? ""
    @

  remove_term: ->
    @remove()

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


