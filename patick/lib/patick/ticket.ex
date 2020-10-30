defmodule Patick.Ticket do
  @moduledoc """
  Schema that models the tickets table in the postgres
  database. It contains all the business logic that are
  related to ticket interaction.

  Defines the model attributes `@lot_spaces` and
  `@keys_to_json`. The last one will be used by
  `Jason.Encoder` to determine which schema fields to encode.

  The payment_method field uses The `PaytmentMethodEnum`
  custom type.

  """
  use Ecto.Schema
  import Ecto.Query
  alias Patick.{Ticket, Repo, PaymentMethodEnum}

  @lot_spaces 54
  @keys_to_json [:code, :is_paid?, :payment_method, :inserted_at, :updated_at]

  @derive {Jason.Encoder, only: @keys_to_json}
  schema "tickets" do
    field :code, :string, size: 16
    field :is_paid?, :boolean, default: false
    field :payment_method, PaymentMethodEnum
    timestamps()
  end

  @doc """
  Creates a ticket struct and inserts it in the tickets
  table.

  Returns a binary which is and hexadecimal string with 16
  characters.
  """

  @spec create() :: binary()
  def create() do
    code = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    %Ticket{code: code} |> Repo.insert()
    code
  end

  @doc """
  Updates the ticket paryment_method and sets is_paid? to
  true.

  Returns the updated ticket.
  """

  @type t :: %__MODULE__{
          id: integer,
          code: binary,
          is_paid?: boolean,
          payment_method: payment_method,
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @type payment_method :: Patick.PaymentMethodEnum.t()

  @spec pay(t(), payment_method) ::
          {:ok, t} | {:error, Ecto.Changeset.t()}
  def pay(%Ticket{} = ticket, payment_method) do
    ticket
    |> Ecto.Changeset.change(is_paid?: true, payment_method: payment_method)
    |> Repo.update()
  end

  @doc """
  Calculates the ticket price. The price is 2 euros for
  started hour. Return 0 if the ticket is already paid.

  """

  @spec calculate_price(t) :: integer
  def calulate_price(%Ticket{is_paid?: true}), do: 0

  def calculate_price(%Ticket{inserted_at: inserted_at}) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.diff(inserted_at)
    |> Kernel./(60 * 60)
    |> Kernel.abs()
    |> Kernel.ceil()
    |> Kernel.*(2)
  end

  @doc """
  Checks if the ticket was paid in the last 15 minutes
  window.

  """

  @spec allowed_to_leave?(t) :: boolean
  def allowed_to_leave?(%Ticket{updated_at: updated_at}) do
    updated_at
    |> NaiveDateTime.add(60 * 15, :second)
    |> NaiveDateTime.compare(NaiveDateTime.utc_now())
    |> Kernel.==(:gt)
  end

  @doc """
  Calculates the parking lot free spaces, this is done by
  substracting the number of tickets in the `tickets` table
  from the `@lot_spaces` attribute.

  """

  @spec free_spaces() :: integer
  def free_spaces() do
    q =
      from t in "tickets",
        select: count(t.id)

    @lot_spaces - Repo.one(q)
  end
end
