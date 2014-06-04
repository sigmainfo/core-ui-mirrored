#= require environment
#= require views/terms/term_view
#= require templates/terms/edit_term

class Coreon.Views.Terms.EditTermView extends Coreon.Views.Terms.TermView

  className: 'term edit'

  initialize: (options = {}) ->
    options.template ?= Coreon.Templates['terms/edit_term']
    super options
