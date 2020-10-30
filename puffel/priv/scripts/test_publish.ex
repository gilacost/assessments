project_id = 209_930_607_165
topic_name = "puffel-dev-topic"
message = "This is a test message"

# {:ok, _started} = Application.ensure_all_started(:goth)
:httpc.set_options(pipeline_timeout: 1000)
# Authenticate
{:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
conn = GoogleApi.PubSub.V1.Connection.new(token.token)

# Build the PublishRequest struct
request = %GoogleApi.PubSub.V1.Model.PublishRequest{
  messages: [
    %GoogleApi.PubSub.V1.Model.PubsubMessage{
      data: Base.encode64(message)
    }
  ]
}

# Make the API request.
{:ok, response} =
  GoogleApi.PubSub.V1.Api.Projects.pubsub_projects_topics_publish(
    conn,
    project_id,
    topic_name,
    body: request
  )

"published message #{response.messageIds}"
|> (&IO.ANSI.format([:green, :bright, &1])).()
|> IO.puts()
