#= require environment
#= require views/terms/abstract_terms_view
#= require views/terms/edit_term_view
#= require templates/terms/edit_terms

class Coreon.Views.Terms.EditTermsView extends Coreon.Views.Terms.AbstractTermsView

  className: ->
    "#{super} edit"

  initialize: (options = {}) ->
    options.template ?= Coreon.Templates['terms/edit_terms']
    super options

  createSubview: (model) ->
    new Coreon.Views.Terms.EditTermView model: model
