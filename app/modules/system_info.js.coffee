  #= require environment

  Coreon.Modules.SystemInfo =

    info: ->
      info = id: @id
      defaults = ( key for key, value of @defaults() )
      defaults.push @idAttribute
      for key, value of @attributes when key not in defaults
        info[key] = value
      info
