class SomeJob < ApplicationJob
  def perform
    PostResource.all.as_json
  end

  def action_name
    "jobby"
  end
end
