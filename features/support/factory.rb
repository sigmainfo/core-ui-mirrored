module Api
  module Graph
    module Factory
      def create_concept_with_id(id, properties)
        concept = Api::Graph::Concept.new
        concept.id = id
        concept.save!
        properties.each do |key, value|
          concept.properties.create! key: key.to_s, value: value
        end
        concept
      end

      def create_term(value, lang = "en")
        concept = Api::Graph::Concept.create!
        term = concept.terms.create! value: value, lang: lang
        concept.save!
        term
      end
    end
  end
end
