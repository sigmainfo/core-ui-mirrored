class Api::Graph::ConceptsController < ApplicationController

  before_filter :authenticate

  def search
    regexp = Regexp.new( Regexp.escape(params["search"]["query"]), Regexp::IGNORECASE )
    concepts_by_prop = Api::Graph::Concept.elem_match properties: { value: regexp }
    concepts_by_term = Api::Graph::Term.where(value: regexp).map &:concept
    concepts = concepts_by_prop | concepts_by_term

    render json: {
      total:concepts.count,
      per_page: 30,
      current_page: 1,
      hits: concepts.map do |concept|
        {
          score: 1.0 / ( Text::Levenshtein.distance(concept.properties[0].value, params["search"]["query"]) + 1 ),
          result: concept
        }
      end.sort { |a, b| b[:score] <=> a[:score] }
    }
  end

end
