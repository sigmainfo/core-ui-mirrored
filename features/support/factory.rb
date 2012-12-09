module Api
  module Graph
    module Factory
      def create_concept attributes
        response = CoreAPI.post( "concepts", concept: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def create_concept_with_label label, attributes = {}
        create_concept attributes.merge( properties: [{key: "label", value: label}] )
      end

      def create_concept_property concept, attributes
        response = CoreAPI.post( "concepts/#{concept['_id']}/properties", property: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end
      
      def update_concept_property concept, property, attributes
        response = CoreAPI.put( "concepts/#{concept['_id']}/properties/#{property['_id']}", property: attributes )
        unless response.success?
          raise response.body
        end
      end
      
      def create_concept_term concept, attributes
        response = CoreAPI.post( "concepts/#{concept['_id']}/terms", term: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end
      
      def update_concept_term concept, term, attributes
        response = CoreAPI.put( "concepts/#{concept['_id']}/terms/#{term['_id']}", term: attributes )
        unless response.success?
          raise response.body
        end
      end
      
      def create_concept_term_property concept, term, attributes
        response = CoreAPI.post( "concepts/#{concept['_id']}/terms/#{term['_id']}/properties", property: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end
      
      def update_concept_term_property concept, term, prop, attributes
        response = CoreAPI.put( "concepts/#{concept['_id']}/terms/#{term['_id']}/properties/#{prop['_id']}", property: attributes )
        unless response.success?
          raise response.body
        end
      end
      
      def create_edge attributes
        response = CoreAPI.post( "edges", edge: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def link_narrower_to_broader narrower, broader
        create_edge({
          source_node_type: 'Concept', 
          source_node_id: broader['_id'],
          edge_type: 'SUPERCONCEPT_OF',
          target_node_type: 'Concept',
          target_node_id: narrower['_id']
        })
      end

      def create_taxonomy attributes
        response = CoreAPI.post( "taxonomies", taxonomy: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def create_taxonomy_taxonomy_node taxonomy, attributes
        response = CoreAPI.post( "taxonomies/#{taxonomy['_id']}/taxonomy_nodes", taxonomy_node: attributes )
        unless response.success?
          raise response.body
        end
        response.json
      end

    end
  end
end
