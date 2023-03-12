require_relative "rails_helper"

RSpec.describe "context", type: :request do
  let!(:post) { create(:post) }

  it "is assigned to the controller automatically" do
    jsonapi_get "/api/v1/posts/#{post.id}"

    json = JSON.parse(response.body)
    expect(json["data"]["attributes"]["controller"]).to eq("PostsController")
    expect(json["data"]["attributes"]["action"]).to eq("show")
  end

  it "is assigned to the job automatically" do
    expect(SomeJob.perform_now).to include(
      data: [hash_including(controller: "SomeJob")])
  end
end
