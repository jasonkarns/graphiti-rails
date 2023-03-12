module Graphiti::Rails::RakeHelpers
  extend RescueRegistry::RailsTestHelpers

  def self.included(klass)
    klass.class_eval do
      setup_rails!
    end
  end

  def self.extended(other)
    other.instance_eval do
      setup_rails!
    end
  end

  module_function

  def session
    @session ||= ActionDispatch::Integration::Session.new(::Rails.application)
  end

  def setup_rails!
    ::Rails.application.eager_load!
    ::Rails.application.config.cache_classes = true
    ::Rails.application.config.action_controller.perform_caching = false
  end

  def make_request(path, debug = false)
    if path.split("/").length == 2
      path = "#{ApplicationResource.endpoint_namespace}#{path}"
    end
    path << if path.include?("?")
      "&cache=bust"
    else
      "?cache=bust"
    end
    path = "#{path}&debug=true" if debug
    handle_request_exceptions do
      headers = {
        "Authorization": ENV['AUTHORIZATION_HEADER']
      }.compact
      session.get(path.to_s, headers: headers)
    end
    JSON.parse(session.response.body)
  end
end
