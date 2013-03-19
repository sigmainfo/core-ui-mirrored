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
    "click .system-info-toggle:not(.terms *)": "toggleInfo"

  initialize: ->
    super
    @model.on "change", @render, @

  render: ->
    @clear()
    @$el.html @template concept: @model, info: @info(data: @model.info())
    #if @model.get("super_concept_ids")?.length + @model.get("sub_concept_ids")?.length > 0
    @append new Coreon.Views.Concepts.ConceptTreeView model: @model
    if @model.get("properties")?.length > 0
      @append new Coreon.Views.Properties.PropertiesView model: @model
    if @model.get("terms")?.length > 0
      @append new Coreon.Views.Terms.TermsView model: @model
    super

  toggleInfo: ->
    @$(".system-info").not(".terms *").slideToggle()
