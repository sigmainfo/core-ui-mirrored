#= require environment
#= require views/terms/term_view
#= require templates/terms/edit_term
#= require modules/confirmation
#= require models/notification

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
    @$el.hide()
    @model.destroy()
      .done =>
        message = I18n.t 'notifications.term.deleted', value: @model.get('value')
        Coreon.Models.Notification.info message
        @remove()
      .fail =>
        @$el.show()
