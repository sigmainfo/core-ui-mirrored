#= require environment
#= require templates/terms/create_term
# require views/properties/create_term_properties_view

class Coreon.Views.Terms.CreateTermView extends Backbone.View

  className: "create-term"

  template: Coreon.Templates["terms/create_term"]

  render: ->
    @$el.empty()
    @$el.html @template term: @model, id: @model.cid
    @

#  events:
#    'click .remove_term': 'remove_term'
#    'change .term input': 'input_changed'
#
#    @$el.html @template term: @options.term, id: @options.id
#    create_term_properties_view = new Coreon.Views.Properties.CreateTermPropertiesView model: @model, term_id: @options.id
#    create_term_properties_view.render()
#    @$el.append create_term_properties_view.el
#
#  input_changed: (event) ->
#    element = $(event.target)
#    [all, index, key] = element[0].name.match /\[(\d+)\]\[([^[]+)\]$/
#    terms = @model.get "terms"
#    terms[index][key] = element.val()
#    #TODO: implement nested attributes
#    @model.set "terms", terms
#    @model.trigger "change:terms"
#
#  remove_term: (event) =>
#    element = $(event.target)
#    terms = @model.get "terms"
#    terms.splice element.attr("data-id"), 1
#    @model.set "terms", terms
#    @model.trigger "change:terms"
#    @$el.empty()

