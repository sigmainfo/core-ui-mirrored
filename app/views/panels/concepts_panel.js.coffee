#= require environment
#= require views/panels/panel_view
#= require helpers/titlebar
#= require templates/panels/concepts
#= require views/panels/concepts/repository_view
#= require views/panels/concepts/concept_list_view
#= require views/panels/concepts/concept_view

class Coreon.Views.Panels.ConceptsPanel extends Coreon.Views.Panels.PanelView

  layout: Coreon.Templates['panels/concepts']

  current: null

  initialize: ->
    @$el.html @layout()

    @switchView()

    @stopListening()
    @listenTo @model
            , 'change:selection change:scope change:repository'
            , @switchView

  switchView: ->
    @currentView?.remove()

    @currentView =
      if selection = @model.get 'selection'
        if @model.get('scope') is 'single'
          new Coreon.Views.Panels.Concepts.ConceptView
            model: selection.first()
        else
          new Coreon.Views.Panels.Concepts.ConceptListView
            model: selection
      else
        new Coreon.Views.Panels.Concepts.RepositoryView
          model: @model.get('repository')

    @$('.content').append @currentView.render().$el

  render: ->
    @currentView.render()
    @
