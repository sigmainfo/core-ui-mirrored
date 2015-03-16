class Coreon.Formatters.RelationsFormatter

  constructor: (@relationTypes = [], @edgesIn = [], @edgesOut = []) ->

  associativeRelations: ->
    groups = []
    _(@relationTypes).each (type) =>
      if type.type is 'associative'
        relations = []
        _(@edgesIn).each (relation) =>
          if relation.edge_type is type.key
            formatted = {
              id: relation.source_node_id
            }
            relations.push formatted
        _(@edgesOut).each (relation) =>
          if relation.edge_type is type.key
            formatted = {
              id: relation.target_node_id
            }
            relations.push formatted

        group = {
          relationType: type
          relations: relations
        }
        groups.push group

    groups
