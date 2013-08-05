#= require environment
#= require jquery.ui.position
#= require templates/widgets/search_target_select
#= require views/widgets/search_target_select_dropdown_view
#= require modules/helpers
#= require modules/prompt

class Coreon.Views.Widgets.SearchTargetSelectView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Prompt

  id: "coreon-search-target-select"

  template: Coreon.Templates["widgets/search_target_select"]

  events:
    "click .toggle" : "showDropdown"
    "click .hint"   : "onFocus"

  initialize: ->
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template selectedType: @model.getSelectedType() 
    @

  showDropdown: (event) ->
    dropdown = new Coreon.Views.Widgets.SearchTargetSelectDropdownView
      model: @model
    @prompt dropdown
    input = $("#coreon-search-query")
    $("#coreon-modal .options")
      .width( input.outerWidth() - 1 )
      .position(
        my: "left+1 top"
        at: "left bottom"
        of: input
      )

  hideHint: ->
    @$(".hint").hide()

  revealHint: ->
    @$(".hint").show()

  onFocus: (event) ->
    @hideHint() 
    @trigger "focus"
