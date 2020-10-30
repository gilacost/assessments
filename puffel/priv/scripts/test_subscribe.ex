project_id = 209_930_607_165
subscription_name = "puffel-dev-subscription"
{:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
conn = GoogleApi.PubSub.V1.Connection.new(token.token)

# Make a subscription pull
{:ok, response} =
  GoogleApi.PubSub.V1.Api.Projects.pubsub_projects_subscriptions_pull(
    conn,
    project_id,
    subscription_name,
    body: %GoogleApi.PubSub.V1.Model.PullRequest{
      maxMessages: 10
    }
  )

if response.receivedMessages != nil do
  Enum.each(response.receivedMessages, fn message ->
    # Acknowledge the message was received
    GoogleApi.PubSub.V1.Api.Projects.pubsub_projects_subscriptions_acknowledge(
      conn,
      project_id,
      subscription_name,
      body: %GoogleApi.PubSub.V1.Model.AcknowledgeRequest{
        ackIds: [message.ackId]
      }
    )

    "received and acknowledged message: #{Base.decode64!(message.message.data)}"
    |> (&IO.ANSI.format([:green, :bright, &1])).()
    |> IO.puts()
  end)
end
