#= require environment
#= require templates/widgets/term_list
#= require templates/widgets/term_list_info

class Coreon.Views.Widgets.TermListView extends Backbone.View

  id: 'coreon-term-list'

  className: 'widget'

  template: Coreon.Templates['widgets/term_list']
  info    : Coreon.Templates['widgets/term_list_info']

  initialize: ->
    @$el.html @template()
    @stopListening()
    @listenTo Coreon.application.repositorySettings(), 'change:sourceLanguage', @render

  render: ->
    ul = @$ 'ul'
    if Coreon.application.repositorySettings('sourceLanguage') is 'none'
      ul.html @info()
    else
      ul.html ''
    @
