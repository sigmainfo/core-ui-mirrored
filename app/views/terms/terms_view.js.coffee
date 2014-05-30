#= require environment
#= require views/terms/abstract_terms_view
#= require templates/terms/terms
#= require views/terms/term_view

class Coreon.Views.Terms.TermsView extends Coreon.Views.Terms.AbstractTermsView

  className: ->
    "#{super} show"

  initialize: (options = {}) ->
    options.template ?= Coreon.Templates['terms/terms']
    super options

  createSubview: (model) ->
    new Coreon.Views.Terms.TermView model: model
