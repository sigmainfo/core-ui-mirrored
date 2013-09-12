  #= require environment

  Coreon.Modules.SystemInfo =

    info: ->
      info = @get('admin') || {}
      for attr in ['id', 'created_at', 'updated_at']
        info[attr] = @get(attr)

      info
