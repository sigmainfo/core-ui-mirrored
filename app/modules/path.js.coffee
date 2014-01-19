#= require environment

Coreon.Modules.Path =

  repositoryPath: ->
    Coreon.application.repository().path()

  pathTo: ( fragments... ) ->
    fragments = fragments.map ( fragment ) ->
        fragment.replace /^\//, ''
    fragments.unshift @repositoryPath()
    fragments
      .map ( fragment ) ->
        fragment.replace /\/$/, ''
      .join '/'

  path: ->
    if @isNew()
     'javascript:void(0)'
    else
     @pathTo @pathName, @id
