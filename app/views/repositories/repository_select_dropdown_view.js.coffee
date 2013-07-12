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
    "click"        : "close"
    "click li a"   : "select"
    "mouseover li" : "onFocus"
    "mouseout li"  : "onBlur"

  initialize: ->
    $(document).on "keydown", @onKeydown

  render: ->
    current = @model.currentRepository()
    repositories = (repository for repository in @model.get("repositories") when repository.id isnt current.id)
    @$el.html @template repositories: repositories
    @

  close: (event) =>
    @options.app.prompt null

  select: (event) =>
    event.preventDefault()
    Backbone.history.navigate $(event.target).attr("href"), trigger: yes

  onFocus: (event) =>
    @$("li.option.focus").removeClass "focus"
    $(event.target).closest("li").addClass "focus"

  onBlur: (event) =>
    @$("li.option.focus").removeClass "focus"

  onKeydown: (event) =>
    current = @$("li.option.focus").first()
    switch event.keyCode
      when KEYCODE.esc
        @options.app.prompt null
      when KEYCODE.enter
        if current.length > 0
          Backbone.history.navigate current.find("a").attr("href"), trigger: yes
        @options.app.prompt null
      when KEYCODE.down
        if current.length > 0
          next = current.next()
          if next.length > 0
            current.removeClass "focus"
            next.addClass "focus"
        else
          @$("li.option").first().addClass "focus"
      when KEYCODE.up
        if current.length > 0
          prev = current.prev()
          if prev.length > 0
            current.removeClass "focus"
            prev.addClass "focus"
        else
          @$("li.option").last().addClass "focus"

  remove: ->
    $(document).off "keydown"
    super
