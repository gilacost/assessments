defmodule Patick.Repo.Migrations.AddPaymentToTicketsTable do
  use Ecto.Migration
  alias Patick.PaymentMethodEnum

  def change do
    PaymentMethodEnum.create_type()

    alter table("tickets") do
      add :is_paid?, :boolean, default: false
      add :payment_method, PaymentMethodEnum.type()
    end
  end
end
