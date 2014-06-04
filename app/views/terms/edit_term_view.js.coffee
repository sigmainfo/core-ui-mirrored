#= require environment
#= require views/terms/term_view
#= require templates/terms/edit_term
#= require modules/confirmation

class Coreon.Views.Terms.EditTermView extends Coreon.Views.Terms.TermView

  _(@::).extend Coreon.Modules.Confirmation

  className: 'term edit'

  events:
    'click .remove-term': 'removeTerm'

  initialize: (options = {}) ->
    options.template ?= Coreon.Templates['terms/edit_term']
    super options

  removeTerm: (event) ->
    @confirm
      trigger: event.target
      container: @el
      message: I18n.t 'term.confirm.remove_term'
      action: 'destroyTerm'

  destroyTerm: ->
    console.log @, @model
