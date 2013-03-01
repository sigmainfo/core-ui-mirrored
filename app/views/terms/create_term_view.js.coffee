#= require environment
#= require templates/terms/create_term
# require views/properties/create_term_properties_view

class Coreon.Views.Terms.CreateTermView extends Backbone.View

  className: "create-term"

  template: Coreon.Templates["terms/create_term"]

  events:
    'change input': 'input_changed'
#    'click .remove_term': 'remove_term'
#

  render: ->
    @$el.empty()
    @$el.html @template term: @model, id: @model.cid
    @

  input_changed: (event) ->
    element = $(event.target)
    [all, attr] = element[0].name.match /\[([^[]+)\]$/
    @model.set attr, element[0].value


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

