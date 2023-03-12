class PublishJob < ApplicationJob
  def perform
    PostResource.all.as_json
  end

  # stub method used solely because the
  # PostResource expects its graphiti-context
  # to respond to `#action_name`
  def action_name
    "workin"
  end
end
