#= require environment


#TODO: what about defining rule sets in the closure?


Coreon.Helpers.can = (action, target) ->
  role = Coreon.application.get("session")?.highestRole()
  (action is "read" and (role is "user" or role is "maintainer")) or
  (action isnt "read" and role is "maintainer")
