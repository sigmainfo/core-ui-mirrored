#= require environment

Coreon.Helpers.graphUri = (uri) ->
  graphUri = Coreon.application.graphUri().replace /\/$/, ''
  "#{graphUri}/#{uri}"