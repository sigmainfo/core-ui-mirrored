module Api
  module Graph
    module Factory

      def maintainer_session
        return @maintainer_session if @maintainer_session

        user = CoreClient::Auth::User.create! name: "Given Maintainer", emails: ["maintainer@user.given"], password: "secret123", password_confirmation: "secret123"
        CoreClient::Auth::RepositoryUser.create! repository: current_repository, user: user, email: "maintainer@user.given", roles: [:maintainer], state: :confirmed

        session = CoreClient::Auth.get_session 'maintainer@user.given', 'secret123'

        @maintainer_session = session[:auth_token]
      end

      def create_concept(attributes = {})
        response = CoreAPI.post(
          "concepts",
          {concept: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def create_concept_with_label label, attributes = {}
        create_concept attributes.merge( properties: [{key: "label", value: label}] )
      end

      def create_concept_property concept, attributes
        response = CoreAPI.post(
          "concepts/#{concept['id']}/properties",
          {property: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def update_concept_property concept, property, attributes
        response = CoreAPI.put(
          "concepts/#{concept['id']}/properties/#{property['id']}",
          {property: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
      end

      def create_concept_term concept, attributes
        response = CoreAPI.post(
          "concepts/#{concept['id']}/terms",
          {term: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def update_concept_term concept, term, attributes
        response = CoreAPI.put(
          "concepts/#{concept['id']}/terms/#{term['id']}",
          {term: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
      end

      def create_concept_term_property concept, term, attributes
        response = CoreAPI.post(
          "concepts/#{concept['id']}/terms/#{term['id']}/properties",
          {property: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def update_concept_term_property concept, term, prop, attributes
        response = CoreAPI.put(
          "concepts/#{concept['id']}/terms/#{term['id']}/properties/#{prop['id']}",
          {property: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
      end

      def create_edge attributes
        response = CoreAPI.post(
          "edges",
          {edge: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def link_narrower_to_broader narrower, broader
        create_edge({
          source_node_type: 'Concept',
          source_node_id: broader['id'],
          edge_type: 'SUPERCONCEPT_OF',
          target_node_type: 'Concept',
          target_node_id: narrower['id']
        })
      end

      def create_taxonomy attributes
        response = CoreAPI.post(
          "taxonomies",
          {taxonomy: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

      def create_taxonomy_taxonomy_node taxonomy, attributes
        response = CoreAPI.post(
          "taxonomies/#{taxonomy['id']}/taxonomy_nodes",
          {taxonomy_node: attributes},
          {"X-Core-Session" => maintainer_session}
        )
        unless response.success?
          raise response.body
        end
        response.json
      end

    end
  end
end
