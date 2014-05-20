#= require environment
#= require templates/terms/edit_terms

class Coreon.Views.Terms.EditTermsView extends Backbone.View

  className: 'edit terms'

  initialize: (options = {}) ->
    @template = options.template or Coreon.Templates['terms/edit_terms']

  render: ->
    @$el.html @template()
    @
