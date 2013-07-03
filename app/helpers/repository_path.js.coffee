#= require environment

Coreon.Helpers.repositoryPath = (suffix)->
  repo_id = Coreon.application.get("session").get("current_repository_id")
  path = "/#{repo_id}"
  if suffix
    suffix = suffix.slice(1) if suffix[0] is "/"
    path += "/#{suffix}"
  path
