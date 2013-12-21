#= require environment
#= require helpers/can
#= require helpers/repository_path
#= require templates/repositories/repository

class Coreon.Views.Repositories.RepositoryView extends Backbone.View

  template: Coreon.Templates["repositories/repository"]

  className: "repository show"

  render: ->
    @$el.html @template
      repository: @model
    @
