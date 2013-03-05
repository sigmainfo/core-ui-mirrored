#= require environment
#= require templates/terms/create_term

class Coreon.Views.Terms.CreateTermView extends Backbone.View

  className: "create-term"

  template: Coreon.Templates["terms/create_term"]

  events:
    'change input': 'input_changed'
    'click .remove_term': 'remove_term'

  render: ->
    @$el.empty()
    @$el.html @template term: @model, id: @model.cid
    @

  input_changed: (event) ->
    element = $(event.target)
    [all, attr] = element[0].name.match /\[([^[]+)\]$/
    @model.set attr, element[0].value

  remove_term: (event) ->
    @$el.empty()
    console.log @model.get "collection"
    @model.get("collection")?.remove(@)


