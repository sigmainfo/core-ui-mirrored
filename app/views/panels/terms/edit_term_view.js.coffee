#= require environment
#= require templates/terms/new_term
#= require helpers/form_for
#= require helpers/input
#= require views/properties/edit_properties_view

class Coreon.Views.Panels.Terms.EditTermView extends Backbone.View

  template: Coreon.Templates['terms/new_term']

  render: ->
    @$el.html @template term: @model
    @