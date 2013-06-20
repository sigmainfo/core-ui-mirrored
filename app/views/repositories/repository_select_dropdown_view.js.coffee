#= require environment
#= require templates/repositories/repository_select_dropdown

KEYCODE =
  esc: 27
  enter: 13
  down: 40
  up: 38
 
class Coreon.Views.Repositories.RepositorySelectDropdownView extends Backbone.View

  id: "coreon-repository-select-dropdown"

  template: Coreon.Templates["repositories/repository_select_dropdown"]

  events:
    "mouseover li" : "onFocus"
    "mouseout li"  : "onBlur"

  initialize: ->
    $(document).on "keydown", @onKeydown

  render: ->
    current = @model.currentRepository()
    repositories = (repository for repository in @model.get("repositories") when repository.id isnt current.id)
    @$el.html @template repositories: repositories
    @

  onFocus: (event) =>
    @$("li.option.focus").removeClass "focus"
    $(event.target).closest("li").addClass "focus"

  onBlur: (event) =>
    @$("li.option.focus").removeClass "focus"

  onKeydown: (event) =>
    switch event.keyCode
      when KEYCODE.esc
        @options.app.prompt null
      when KEYCODE.enter
        @$("li.option.focus a").click()
      when KEYCODE.down
        current = @$("li.option.focus").first()
        if current
          if next = current.next()
            current.removeClass "focus"
            next.addClass "focus"
        else
          @$("li.option").first().addClass "focus"
      when KEYCODE.up
        current = @$("li.option.focus").first()
        if current
          if next = current.prev()
            current.removeClass "focus"
            next.addClass "focus"
        else
          @$("li.option").last().addClass "focus"

  remove: ->
    $(document).off "keydown"
