module Resources
  include Authentication

  def blueprint(type)
    blueprints[type.to_s]
  end

  def blueprints
    uri = File.join current_repository.graph_uri,
                    'repository/settings/blueprints'
    RestClient::Resource.new(
      uri,
      headers: {
        content_type: :json,
        accept: :json,
        x_core_session: factory_girl_session
      }
    )
  end
end
