class Api::Graph::TermsController < ApplicationController

  before_filter :authenticate

  def search
    sleep 0.2
    terms = Api::Graph::Term.where(value: Regexp.new(Regexp.escape(params["search"]["query"]), Regexp::IGNORECASE)).order_by :value.asc
    render json: {
      total: terms.count,
      per_page: 30,
      current_page: 1,
      hits: terms.map do |term|
        {
          score: term.value.length.to_f / params["search"]["query"].length,
          result: term
        }
      end
    }
  end

end
