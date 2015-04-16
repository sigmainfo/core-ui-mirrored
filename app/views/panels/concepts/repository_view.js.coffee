#= require environment
#= require helpers/can
#= require helpers/repository_path
#= require templates/panels/concepts/repository

class Coreon.Views.Panels.Concepts.RepositoryView extends Backbone.View

  template: Coreon.Templates['panels/concepts/repository']

  className: 'repository show'

  newConceptPath: ->
    app = Coreon.application
    base = "#{app.get('repository').path()}/concepts"
    lang = app.lang()
    "#{base}/new/terms/#{lang}/"

  render: ->
    @$el.html @template
      repository: @model
      newConceptPath: @newConceptPath()
    @
