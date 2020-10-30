defmodule Puffel.PubSub do
  @moduledoc """
  TODO
  """
  use GenServer

  # Client
  @spec start_link(list()) :: {:ok, pid} | {:error, term}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  TODO
  """
  @spec publish(String.t()) :: :ok
  def publish(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end

  # Server(callbacks))
  @impl true
  def init(state) do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    conn = GoogleApi.PubSub.V1.Connection.new(token.token)
    new_state = state ++ [conn]
    schedule_pulling()
    {:ok, new_state}
  end

  @impl true
  def handle_cast({:publish, message}, [project_id, topic_name, _, conn] = state) do
    request = %GoogleApi.PubSub.V1.Model.PublishRequest{
      messages: [
        %GoogleApi.PubSub.V1.Model.PubsubMessage{
          data: Base.encode64(message)
        }
      ]
    }

    try do
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
    catch
      error -> IO.inspect(error)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:pull, [project_id, _, subscription_name, conn] = state) do
    try do
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
    catch
      error -> IO.inspect(error)
    end

    schedule_pulling()
    {:noreply, state}
  end

  @spec schedule_pulling() :: reference()
  defp schedule_pulling() do
    Process.send_after(self(), :pull, 1000)
  end
end
