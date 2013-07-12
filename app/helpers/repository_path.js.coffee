#= require environment

Coreon.Helpers.repositoryPath = (fragments...)->
  repo_id = Coreon.application.get("session").get("current_repository_id")
  path = "/#{repo_id}/"
  fragments = fragments[0] if $.isArray(fragments[0])
  for fragment in fragments
    fragment = encodeURIComponent(fragment.replace(/^\//, "").replace(/\/$/, ""))
    path = path + fragment + "/"

  path.slice(0,-1)

