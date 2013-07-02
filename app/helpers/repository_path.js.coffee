#= require environment

Coreon.Helpers.repositoryPath = (suffix)->
  repo_id = Coreon.application.get("session").get("current_repository_id")
  suffix = suffix.slice(1) if suffix[0] is "/"
  path = "/#{repo_id}/#{suffix}"
