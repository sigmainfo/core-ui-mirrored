#= require environment
#= require templates/widgets/search_target_select
#= require views/widgets/search_target_select_dropdown_view

class Coreon.Views.Widgets.SearchTargetSelectView extends Backbone.View

  id: "coreon-search-target-select"

  template: Coreon.Templates["widgets/search_target_select"]

  events:
    "click .toggle": "showDropdown"

  initialize: ->
    @searchType = new Backbone.Model
      options: ["all", "definition", "terms"]
      selected: 0
    @dropdown = new Coreon.Views.Widgets.SearchTargetSelectDropdownView model: @searchType 

  render: ->
    @$el.html @template()
    @

  showDropdown: (event) ->
    $("#coreon-modal").append @dropdown.render().$el
