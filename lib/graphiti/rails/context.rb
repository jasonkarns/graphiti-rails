module Graphiti
  module Rails
    # Provides a [Graphiti Context](https://www.graphiti.dev/guides/concepts/resources#context)
    # to wrap callbacks like
    # [`#around_action`](https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action)
    # or [`#around_perform`](https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform)
    # which points to the including instance (eg, controller or job) by default.
    module Context
      extend ActiveSupport::Concern

      included do
        include Graphiti::Context
      end

      # The context to use for Graphiti Resources.
      # Defaults to the including instance (eg, controller or job).
      # Can be redefined for different behavior.
      def graphiti_context
        if respond_to?(:jsonapi_context)
          DEPRECATOR.deprecation_warning("Overriding jsonapi_context", "Override #graphiti_context instead")
          jsonapi_context
        else
          self
        end
      end

      # Wraps controller actions in a
      # [Graphiti Context](https://www.graphiti.dev/guides/concepts/resources#context)
      # which points to the controller instance by default.
      concern :ForControllers do
        included do
          include Graphiti::Rails::Context
          around_action :wrap_graphiti_context
        end

        # Called by [`#around_action`](https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action)
        # to wrap the current action in a Graphiti context defined by {#graphiti_context}.
        def wrap_graphiti_context
          Graphiti.with_context(graphiti_context, action_name.to_sym) do
            yield
          end
        end
      end

      # Wraps active jobs in a
      # [Graphiti Context](https://www.graphiti.dev/guides/concepts/resources#context)
      # which points to the job instance by default.
      concern :ForJobs do
        included do
          include Graphiti::Rails::Context
          around_perform :wrap_graphiti_context
        end

        # Called by [`#around_perform`](https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform)
        # to wrap the current job's {#perform} in a Graphiti context defined by {#graphiti_context}.
        def wrap_graphiti_context
          Graphiti.with_context(graphiti_context) do
            yield
          end
        end
      end
    end
  end
end
