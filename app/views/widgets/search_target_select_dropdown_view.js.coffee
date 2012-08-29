#= require environment
#= require templates/widgets/search_target_select_dropdown

class Coreon.Views.Widgets.SearchTargetSelectDropdownView extends Backbone.View 

  id: "coreon-search-target-select-dropdown"

  template: Coreon.Templates["widgets/search_target_select_dropdown"]

  render: ->
    @$el.html @template
      options: @model.get "options"
      selected: @model.get "selected"
    @
