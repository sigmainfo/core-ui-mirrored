#= require environment
#= require templates/terms/create_terms
#= require views/terms/create_term_view

class Coreon.Views.Terms.CreateTermsView extends Backbone.View

  className: "create-terms"

  template: Coreon.Templates["terms/create_terms"]

  events:
    'click .add_term': 'add_term'

  render: ->
    @$el.empty()
    @$el.html @template
    for term, id in @model.get "terms"
      create_term_view = new Coreon.Views.Terms.CreateTermView model: @model, term: term, id: id
      create_term_view.render()
      @$el.append create_term_view.el
    console.log @model._label()
    console.log @model.get "label"

  add_term: (event) =>
    terms = @model.get "terms"
    terms.push { value: "", lang: "", properties: [] }
    @model.set "terms", terms
    @render()

