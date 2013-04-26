#= require environment

Coreon.Helpers.can = (action, target) -> Coreon.application?.session.ability.can action, target
