#= require environment

class Coreon.Views.Repositories.RepositorySelectDropdownView extends Backbone.View

    id: "coreon-repository-select-dropdown"

    template: Coreon.Templates["repositories/repository_select_dropdown"]

    render: ->
      @$el.html @template()
      @
