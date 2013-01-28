#= require environment

Coreon.Modules =

  extend: (target, modules...) ->
    for module in modules
      target[key] = value for key, value of module
    target

  include: (target, modules...) ->
    for module in modules
      for key, value of module
        target::[key] = value 
    target
