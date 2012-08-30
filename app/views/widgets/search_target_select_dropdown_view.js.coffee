#= require environment
#= require templates/widgets/search_target_select_dropdown

class Coreon.Views.Widgets.SearchTargetSelectDropdownView extends Backbone.View 

  id: "coreon-search-target-select-dropdown"

  template: Coreon.Templates["widgets/search_target_select_dropdown"]

  events:
    "click": "onClick"
    "click li": "onSelect"

  render: ->
    @$el.html @template
      options: @model.get "availableTypes"
      selected: @model.get "selectedTypeIndex"
    @

  onClick: (event) ->
    @undelegateEvents()
    @remove()

  onSelect: (event) ->
    @model.set "selectedTypeIndex", $(event.target).index()
