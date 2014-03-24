#= require environment
#= require views/panels/concepts_panel
#= require views/panels/clipboard_panel
#= require views/panels/concept_map_panel
#= require views/panels/term_list_panel
#= require collections/concept_map_nodes
#= require collections/hits
#= require models/term_list

class Coreon.Lib.Panels.PanelFactory

  @instance: =>
    @_instance ?= new @ Coreon.application

  constructor: (@app) ->

  create: (type, model) ->
    switch type
      when 'concepts'
        new Coreon.Views.Panels.ConceptsPanel
          model: @app
          panel: model
      when 'clipboard'
        new Coreon.Views.Panels.ClipboardPanel
          panel: model
      when 'conceptMap'
        new Coreon.Views.Panels.ConceptMapPanel
          model: new Coreon.Collections.ConceptMapNodes
          hits: Coreon.Collections.Hits.collection()
          panel: model
      when 'termList'
        new Coreon.Views.Panels.TermListPanel
          model: new Coreon.Models.TermList
          panel: model
      else
        throw new Error("Unknown panel type: #{type}")
