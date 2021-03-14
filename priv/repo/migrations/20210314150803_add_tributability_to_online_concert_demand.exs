defmodule Tune.Repo.Migrations.AddTributabilityToOnlineConcertDemand do
  use Ecto.Migration

  def change do
    alter table(:online_concert_demands) do
      add :is_tributable, :boolean
    end
  end
end
