#= require environment
#= require views/composite_view
#= require templates/concepts/concept
#= require templates/layout/info
#= require views/concepts/concept_tree_view
#= require views/properties/properties_view
#= require views/terms/terms_view

class Coreon.Views.Concepts.ConceptView extends Coreon.Views.CompositeView

  className: "concept"

  template: Coreon.Templates["concepts/concept"]
  info: Coreon.Templates["layout/info"]

  events:
    "click .system-info-toggle": "toggleInfo"

  initialize: ->
    super
    @model.on "change", @render, @

  render: ->
    @$el.html @template concept: @model, info: @info(data: @model.info())
    if @model.get("super_concept_ids")?.length + @model.get("sub_concept_ids")?.length > 0
      tree = new Coreon.Views.Concepts.ConceptTreeView model: @model
      @$el.append tree.render().$el
    if @model.get("properties")?.length > 0
      props = new Coreon.Views.Properties.PropertiesView model: @model
      @$el.append props.render().$el
    if @model.get("terms")?.length > 0
      terms = new Coreon.Views.Terms.TermsView model: @model
      @$el.append terms.render().$el
    @

  toggleInfo: ->
    @$(".system-info").slideToggle()
